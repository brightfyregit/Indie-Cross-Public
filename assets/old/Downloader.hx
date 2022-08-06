package;

import format.tgz.Data;
import format.tgz.Reader;
import haxe.Http;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.Output;
import haxe.io.Path;
import sys.io.File;

class Downloader
{
	private var http:Http;
	var fileStream:Output;

	public function new()
	{
		// friendly reminder that you should buy a health insurance
		Sys.println("yoo you want to download a file wtf!?!?!?");
	}

	// only for secret song shit
	public function download(leUrl:String, path:String, zip:Bool = false):Void
	{
		http = new Http(leUrl);
		var output:BytesOutput = new BytesOutput();
		http.customRequest(false, output);
		// File.saveBytes(path + 'hi.zip', output.getBytes());

		if (!zip)
		{
			/* 
				YO I TRIED THIS AND IT FUCKING WORKS
				LETS FUCKING GOOOOO
				tgz is 1.66 mb long
			 */
			File.saveBytes(path + 'hi.tar.gz', output.getBytes());
		}
		else
		{
			// var leZip = File.getBytes(path + 'hi.zip');
			var archive:Data = new Reader(new BytesInput(output.getBytes())).read();

			for (file in archive)
			{
				var filePath:String = Path.join([path, file.fileName]);

				Sys.println("Extracting! - " + file.fileName);
				File.saveBytes(filePath, file.data);
			}
		}
	}
}
