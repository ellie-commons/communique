//	This file is part of FeedReader.
//
//	FeedReader is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	FeedReader is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with FeedReader.  If not, see <http://www.gnu.org/licenses/>.

public class FeedReader.InstaAPI : ShareAccountInterface, Peas.ExtensionBase {

	public InstaAPI()
	{

	}

	public void setupSystemAccounts(Gee.List<ShareAccount> accounts)
	{

	}

	public string getRequestToken()
	{
		return "";
	}

	public bool getAccessToken(string id, string username, string password)
	{
		// Use Instapaper Simple API to verify credentials
		var session = new Soup.Session();
		session.user_agent = Constants.USER_AGENT;

		string auth_data = "username=" + GLib.Uri.escape_string(username)
			+ "&password=" + GLib.Uri.escape_string(password);

		var message = new Soup.Message("POST", "https://www.instapaper.com/api/authenticate");
		message.set_request_body_from_bytes("application/x-www-form-urlencoded", new Bytes(auth_data.data));

		try
		{
			session.send_and_read(message);
		}
		catch(Error e)
		{
			Logger.error("instapaper getAccessToken: " + e.message);
			return false;
		}

		if(message.status_code != 200)
		{
			Logger.error("instapaper getAccessToken: authentication failed with status %u".printf(message.status_code));
			return false;
		}

		// Store credentials
		var settings = new GLib.Settings.with_path("com.github.suzie97.communique.share.account", "/com/github/suzie97/communique/share/instapaper/%s/".printf(id));
		settings.set_string("username", username);

		var array = Settings.share("instapaper").get_strv("account-ids");
		array += id;
		Settings.share("instapaper").set_strv("account-ids", array);

		var pwSchema = new Secret.Schema ("com.github.suzie97.communique.instapaper.password", Secret.SchemaFlags.NONE,
			"username", Secret.SchemaAttributeType.STRING);

		var attributes = new GLib.HashTable<string,string>(str_hash, str_equal);
		attributes["username"] = username;
		try
		{
			Secret.password_storev_sync(pwSchema, attributes, Secret.COLLECTION_DEFAULT, "Communique: Instapaper login", password, null);
		}
		catch(GLib.Error e)
		{
			Logger.error("InstaAPI - getAccessToken: " + e.message);
		}

		return true;
	}

	public bool addBookmark(string id, string url, bool system)
	{
		var settings = new GLib.Settings.with_path("com.github.suzie97.communique.share.account", "/com/github/suzie97/communique/share/instapaper/%s/".printf(id));

		var pwSchema = new Secret.Schema ("com.github.suzie97.communique.instapaper.password", Secret.SchemaFlags.NONE, "username", Secret.SchemaAttributeType.STRING);
		var attributes = new GLib.HashTable<string,string>(str_hash, str_equal);
		attributes["username"] = settings.get_string("username");

		string password = "";
		try
		{
			password = Secret.password_lookupv_sync(pwSchema, attributes, null);
		}
		catch(GLib.Error e)
		{
			Logger.error("InstaAPI addBookmark: " + e.message);
		}

		var session = new Soup.Session();
		session.user_agent = Constants.USER_AGENT;
		string username = settings.get_string("username");
		string message = "username=" + GLib.Uri.escape_string(username)
			+ "&password=" + GLib.Uri.escape_string(password)
			+ "&url=" + GLib.Uri.escape_string(url);

		Logger.debug("InstaAPI: adding bookmark for %s".printf(url));

		var message_soup = new Soup.Message("POST", "https://www.instapaper.com/api/add");
		message_soup.set_request_body_from_bytes("application/x-www-form-urlencoded", new Bytes(message.data));

		if(Settings.tweaks().get_boolean("do-not-track"))
		{
			message_soup.request_headers.append("DNT", "1");
		}

		Bytes response_body;
		try
		{
			response_body = session.send_and_read(message_soup);
		}
		catch(Error e)
		{
			Logger.error("InstaAPI addBookmark: " + e.message);
			return false;
		}

		string response = (string)response_body.get_data();

		if(response == null || response == "")
		{
			return false;
		}

		Logger.debug("InstaAPI: " + response);

		return true;
	}

	public bool logout(string id)
	{
		Logger.debug(@"InstaAPI.logout($id)");
		var settings = new GLib.Settings.with_path("com.github.suzie97.communique.share.account", @"/com/github/suzie97/communique/share/instapaper/$id/");
		var pwSchema = new Secret.Schema("com.github.suzie97.communique.instapaper.password",
			Secret.SchemaFlags.NONE, "username", Secret.SchemaAttributeType.STRING);

		var attributes = new GLib.HashTable<string,string>(str_hash, str_equal);
		attributes["username"] = settings.get_string("username");
		bool removed = false;

		Secret.password_clearv.begin(pwSchema, attributes, null, (obj, async_res) => {
			try
			{
				removed = Secret.password_clearv.end(async_res);
				if(!removed)
				{
					Logger.error(@"Could not delete password of InstaAPI account $id");
				}
			}
			catch(GLib.Error e)
			{
				Logger.error("InstaAPI.logout: %s".printf(e.message));
			}
		});

		var keys = settings.list_keys();
		foreach(string key in keys)
		{
			settings.reset(key);
		}

		var array = Settings.share("instapaper").get_strv("account-ids");

		string[] array2 = {};
		foreach(string i in array)
		{
			if(i != id)
			{
				array2 += i;
			}
		}
		Settings.share("instapaper").set_strv("account-ids", array2);
		deleteAccount(id);

		return true;
	}

	public string getIconName()
	{
		return "feed-share-instapaper";
	}

	public string getUsername(string id)
	{
		var settings = new GLib.Settings.with_path("com.github.suzie97.communique.share.account", "/com/github/suzie97/communique/share/instapaper/%s/".printf(id));
		return settings.get_string("username");
	}

	public bool needSetup()
	{
		return true;
	}

	public bool singleInstance()
	{
		return false;
	}

	public bool useSystemAccounts()
	{
		return false;
	}

	public string pluginID()
	{
		return "instapaper";
	}

	public string pluginName()
	{
		return "Instapaper";
	}

	public string getURL(string token)
	{
		return "";
	}

	public ServiceSetup? newSetup_withID(string id, string username)
	{
		return new InstapaperSetup(id, this, username);
	}

	public ServiceSetup? newSetup()
	{
		return new InstapaperSetup(null, this);
	}

	public ServiceSetup? newSystemAccount(string id, string username)
	{
		return null;
	}

	public ShareForm? shareWidget(string url)
	{
		return null;
	}
}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module)
{
	var objmodule = module as Peas.ObjectModule;
	objmodule.register_extension_type(typeof(FeedReader.ShareAccountInterface), typeof(FeedReader.InstaAPI));
}
