package;

class GitHash
{
	public static macro function getGitCommitHash():haxe.macro.Expr.ExprOf<String>
	{
		#if !display
		var process = new sys.io.Process("git", ["rev-parse", "HEAD"]);
		if (process.exitCode() != 0)
		{
			var message = process.stderr.readAll().toString();
			var pos = haxe.macro.Context.currentPos();
			haxe.macro.Context.error("Cannot execute `git rev-parse HEAD`. " + message, pos);
		}

		var commitHash:String = process.stdout.readLine();
		
		return macro $v{commitHash};
		#else
		var commitHash:String = "";
		return macro $v{commitHash};
		#end
	}
}