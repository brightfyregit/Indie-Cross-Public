package;

import flixel.FlxG;
import Sys.sleep;

using StringTools;

#if cpp
import discord_rpc.DiscordRpc;
#end

class DiscordClient
{
	public function new()
	{
		#if cpp
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "858855876760043560",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
		}

		DiscordRpc.shutdown();
		#end
	}

	public static function shutdown()
	{
		#if cpp
		trace('shuttin');
		DiscordRpc.shutdown();
		#end
	}

	static function onReady()
	{
		#if cpp
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "Artwork by IkuAldena"
		});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		#if cpp
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		#end
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		#if cpp
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		// poly is stupid 🙄 -- stfu u piece of shit

		/*
		if (Type.getClass(FlxG.state) == PlayState)
		{
			if (details.contains(PlayState.instance.storyDifficultyText))
			{
				if (details.contains(PlayState.SONG.song))
				{
					details = 'CONFIDENTIAL [' + PlayState.instance.storyDifficultyText + ']';
				}
			}
		}
		else
		{
			trace('aw hell naw im not on playstate');

			if (details.contains('Freeplay - Listening to '))
			{
				details = 'Freeplay - [CONFIDENTIAL]';
			}
		}
		*/

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "Artwork by IkuAldena",
			smallImageKey: smallImageKey,
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});
		#end
	}
}
