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

public class FeedReader.DecsyncListeners : GLib.Object {

	public static void readListener(string[] path, string datetime, string keyString, string valueString, Extra extra)
	{
		readMarkListener(true, path, datetime, keyString, valueString, extra);
	}

	public static void markListener(string[] path, string datetime, string keyString, string valueString, Extra extra)
	{
		readMarkListener(false, path, datetime, keyString, valueString, extra);
	}

	private static void readMarkListener(bool isReadEntry, string[] path, string datetime, string keyString, string valueString, Extra extra)
	{
		try
		{
			var key = Json.from_string(keyString);
			var value = Json.from_string(valueString);
			var articleID = key.get_string();
			var added = value.get_boolean();
			if (isReadEntry)
			{
				Logger.debug((added ? "read " : "unread ") + articleID);
			}
			else
			{
				Logger.debug((added ? "mark " : "unmark ") + articleID);
			}
			var db = DataBase.writeAccess();
			Article? article = db.read_article(articleID);
			if (article == null)
			{
				Logger.info("Unkown article " + articleID);
				return;
			}
			if (isReadEntry)
			{
				article.setUnread(added ? ArticleStatus.READ : ArticleStatus.UNREAD);
			}
			else
			{
				article.setMarked(added ? ArticleStatus.MARKED : ArticleStatus.UNMARKED);
			}
			db.update_article(article);
		}
		catch (GLib.Error e)
		{
			Logger.error(e.message);
		}
	}

	public static void subscriptionListener(string[] path, string datetime, string keyString, string valueString, Extra extra)
	{
		try
		{
			var key = Json.from_string(keyString);
			var value = Json.from_string(valueString);
			var feedID = key.get_string();
			var subscribed = value.get_boolean();
			if (subscribed)
			{
				string outFeedID, errmsg;
				extra.plugin.addFeedWithDecsync(feedID, null, null, out outFeedID, out errmsg, false);
			}
			else
			{
				DataBase.writeAccess().delete_feed(feedID);
			}
		}
		catch (GLib.Error e)
		{
			Logger.error(e.message);
		}
	}

	public static void feedNamesListener(string[] path, string datetime, string keyString, string valueString, Extra extra)
	{
		try
		{
			var key = Json.from_string(keyString);
			var value = Json.from_string(valueString);
			var feedID = key.get_string();
			var name = value.get_string();
			DataBase.writeAccess().rename_feed(feedID, name);
		}
		catch (GLib.Error e)
		{
			Logger.error(e.message);
		}
	}

	public static void categoriesListener(string[] path, string datetime, string keyString, string valueString, Extra extra)
	{
		try
		{
			var key = Json.from_string(keyString);
			var value = Json.from_string(valueString);
			var feedID = key.get_string();
			var db = DataBase.writeAccess();
			var feed = db.read_feed(feedID);
			if (feed == null)
			{
				return;
			}
			var currentCatID = feed.getCatString();
			string newCatID;
			if (value == null || value.is_null())
			{
				newCatID = extra.plugin.uncategorizedID();
			}
			else
			{
				newCatID = value.get_string();
			}
			addCategory(extra, newCatID);
			db.move_feed(feedID, currentCatID, newCatID);
		}
		catch (GLib.Error e)
		{
			Logger.error(e.message);
		}
	}

	public static void categoryNamesListener(string[] path, string datetime, string keyString, string valueString, Extra extra)
	{
		try
		{
			var key = Json.from_string(keyString);
			var value = Json.from_string(valueString);
			var catID = key.get_string();
			var name = value.get_string();
			DataBase.writeAccess().rename_category(catID, name);
			Logger.debug("Renamed category " + catID + " to " + name);
		}
		catch (GLib.Error e)
		{
			Logger.error(e.message);
		}
	}

	public static void categoryParentsListener(string[] path, string datetime, string keyString, string valueString, Extra extra)
	{
		try
		{
			var key = Json.from_string(keyString);
			var value = Json.from_string(valueString);
			var catID = key.get_string();
			string parentID;
			if (value == null || value.is_null())
			{
				parentID = CategoryID.MASTER.to_string();
			}
			else
			{
				parentID = value.get_string();
			}
			addCategory(extra, parentID);
			DataBase.writeAccess().move_category(catID, parentID);
			Logger.debug("Moved category " + catID + " to " + parentID);
		}
		catch (GLib.Error e)
		{
			Logger.error(e.message);
		}
	}

	private static void addCategory(Extra extra, string catID)
	{
		if (catID == extra.plugin.uncategorizedID() || catID == CategoryID.MASTER.to_string() || DataBase.readOnly().read_category(catID) != null)
		{
			return;
		}
		var cat = new Category(catID, catID, 0, 99, CategoryID.MASTER.to_string(), 1);
		DataBase.writeAccess().write_categories(ListUtils.single(cat));
		var catNode = new Json.Node(Json.NodeType.VALUE);
		catNode.set_string(catID);
		var catJson = Json.to_string(catNode, false);
		extra.plugin.m_sync.execute_stored_entry({"categories", "names"}, catJson, extra);
		extra.plugin.m_sync.execute_stored_entry({"categories", "parents"}, catJson, extra);
		Logger.debug("Added category " + catID);
	}
}
