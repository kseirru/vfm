module main

import veb
import zztkm.vdotenv
import os

pub struct App {
pub mut:
	folder string
}

pub struct Context {
	veb.Context
}

@['/']
pub fn (app &App) index(mut ctx Context) veb.Result {
	mut result := "<meta charset='utf-8'><h1 style='text-align: center;'>VFM</h1>
<div style='text-align: center'>"

	files := os.ls(app.folder) or { return ctx.text('500') }
	for file in files {
		result += '<a href="/${file}">${file}</a><br>'
	}

	return ctx.html(result + "<a href='../'>")
}

pub fn (mut ctx Context) not_found() veb.Result {
	// set HTTP status 404
	mut content_list := ctx.req.url.split('/')
	content_list.delete(0)
	content := content_list.join('/')
	file_path := os.getenv('media_folder') + '/' + content
	if !os.exists(file_path) {
		ctx.res.set_status(.not_found)
		return ctx.html('<meta charset="utf-8"><div style="text-align: center;"><h1>Not found!</h1><br><a href="../">Go back</a></div>')
	}

	if !os.is_dir(file_path) {
		return ctx.file(file_path)
	}
	mut result := "<meta charset='utf-8'><h1 style='text-align: center;'>VFM</h1>
<div style='text-align: center'>"

	files := os.ls(os.getenv('media_folder') + '/' + content) or { return ctx.text('500') }
	for file in files {
		result += '<a href="/${content}/${file}">${file}</a><br>'
	}

	return ctx.html(result + "<a href='../'>Go back</a></div>")
}

fn main() {
	vdotenv.load('.env')
	mut app := &App{
		folder: os.getenv('media_folder')
	}
	veb.run[App, Context](mut app, 1337)
}
