//	This file is part of FeedReader.
//
//	FeedReader is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	 (at your option) any later version.
//
//	FeedReader is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with FeedReader.  If not, see <http://www.gnu.org/licenses/>.

public class FeedReader.SettingsDialog : Gtk.Dialog {

	private Gtk.ListBox m_serviceList;
	private Gtk.Stack m_stack;
	private InfoBar m_errorBar;
	private Gtk.HeaderBar m_headerbar;
	private static SettingsDialog? m_dialog = null;
	private GLib.Settings settings;

	public static SettingsDialog get_default () {
		if (m_dialog == null) {
			m_dialog = new SettingsDialog ();
		}

		return m_dialog;
	}

	private SettingsDialog () {
		this.set_transient_for (MainWindow.get_default ());
		this.set_modal (true);
		this.delete_event.connect (hide_on_delete);
		resizable = false;

		m_headerbar = new Gtk.HeaderBar ();
		set_titlebar (m_headerbar);

		m_stack = new Gtk.Stack () {
			margin = 12
		};
		m_stack.set_transition_duration (50);
		m_stack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
		m_stack.set_halign (Gtk.Align.FILL);
		m_stack.add_titled (setup_UI (), "ui", _("Interface"));
		m_stack.add_titled (setup_Internal (), "internal", _("Behaviour"));
		m_stack.add_titled (setup_Service (), "service", _("Share"));

		Gtk.StackSwitcher switcher = new Gtk.StackSwitcher () {
			margin_top = 12,
			halign = Gtk.Align.CENTER
		};
		switcher.set_stack (m_stack);

		m_headerbar.set_custom_title (switcher);

		var close_button = (Gtk.Button) add_button (_("Close"), Gtk.ResponseType.CLOSE);
		close_button.clicked.connect (() => {
	        hide_on_delete ();
	    });

	    get_content_area ().add (m_stack);
	}

	public void showDialog (string panel)
	{
		this.show_all ();
		m_stack.set_visible_child_name (panel);
	}

	private Gtk.Grid setup_UI () {
		var interface_grid = new Gtk.Grid () {
			column_spacing = 12,
			row_spacing = 6
		};

		var only_feeds = new SettingsSwitch (Settings.general (), "only-feeds");
		only_feeds.changed.connect (() => {
			Settings.state ().set_strv ("expanded-categories", Utils.getDefaultExpandedCategories ());
			Settings.state ().set_string ("feedlist-selected-row", "feed -4");
			ColumnView.get_default ().newFeedList (true);
		});

		var only_unread = new SettingsSwitch (Settings.general (), "feedlist-only-show-unread");
		only_unread.changed.connect (() => {
			ColumnView.get_default ().newFeedList ();
		});

		var feedlist_sort = new SettingsCombo (Settings.general (), "feedlist-sort-by", {_("Received"), _("Alphabetically")});
		feedlist_sort.combo_changed.connect (() => {
			ColumnView.get_default ().newFeedList ();
		});

		// Fix gsettings not saving
		var article_sort = new SettingsCombo (Settings.general (), "articlelist-sort-by", {_("Received"), _("Date")});
		article_sort.combo_changed.connect (() => {
			ColumnView.get_default ().newArticleList ();
		});

		var fontfamilly = new SettingsFont (Settings.general (), "font");
		fontfamilly.font_changed.connect (() => {
			ColumnView.get_default ().reloadArticleView ();
		});

		// var font_switch = new Gtk.Switch ();
		// font_switch.notify["active"].connect (() => {
		// 	if (font_switch.active) {
		// 		fontfamilly.sensitive = true;
		// 	} else {
		// 		fontfamilly.sensitive = false;
		// 	}
		// });
		// settings.bind ("font-switch", font_switch, "active", GLib.SettingsBindFlags.DEFAULT);
		var font_switch = new SettingsSwitch (Settings.general (), "font-switch");
		font_switch.notify["active"].connect (() => {
			if (font_switch.active) {
				fontfamilly.sensitive = true;
			} else {
				fontfamilly.sensitive = false;
			}
		});

		interface_grid.attach (new Granite.HeaderLabel (_("Feed List")), 0, 0, 3, 1);
		interface_grid.attach (new SettingsLabel (_("Only show feeds:")), 0, 1, 1, 1);
		interface_grid.attach (only_feeds, 1, 1, 1, 1);
		interface_grid.attach (new SettingsLabel (_("Only show unread:")), 0, 2, 1, 1);
		interface_grid.attach (only_unread, 1, 2, 1, 1);
		interface_grid.attach (new SettingsLabel (_("Sort Feed List by:")), 0, 3, 1, 1);
		interface_grid.attach (feedlist_sort, 1, 3, 2, 1);
		interface_grid.attach (new Granite.HeaderLabel (_("Font")), 0, 4, 3, 1);
		interface_grid.attach (new SettingsLabel (_("Custom Font:")), 0, 5, 1, 1);
		interface_grid.attach (font_switch, 1, 5, 1, 1);
		interface_grid.attach (fontfamilly, 2, 5, 1, 1);


		// var feed_settings = headline (_ ("Feed List:"));

		// var only_feeds = new SettingSwitch (_ ("Only show feeds"), Settings.general (), "only-feeds");
		// only_feeds.changed.connect ( () => {
		// 	Settings.state ().set_strv ("expanded-categories", Utils.getDefaultExpandedCategories ());
		// 	Settings.state ().set_string ("feedlist-selected-row", "feed -4");
		// 	ColumnView.get_default ().newFeedList (true);
		// });

		// var only_unread = new SettingSwitch (_ ("Only show unread"), Settings.general (), "feedlist-only-show-unread");
		// only_unread.changed.connect ( () => {
		// 	ColumnView.get_default ().newFeedList ();
		// });

		// var feedlist_sort = new SettingDropbox (_ ("Sort Feed List by"), Settings.general (), "feedlist-sort-by", {_ ("Received"), _ ("Alphabetically")});
		// feedlist_sort.changed.connect ( () => {
		// 	ColumnView.get_default ().newFeedList ();
		// });

		// // var feedlist_theme = new SettingDropbox (_ ("Theme"), Settings.general (), "feedlist-theme", {_ ("Gtk+"), _ ("Dark"), _ ("elementary")});
		// // feedlist_theme.changed.connect ( () => {
		// // 	MainWindow.get_default ().reloadCSS ();
		// // });

		// var article_settings = headline (_ ("Article List:"));

		// var article_sort = new SettingDropbox (_ ("Sort articles by"), Settings.general (), "articlelist-sort-by", {_ ("Received"), _ ("Date")});
		// article_sort.changed.connect ( () => {
		// 	ColumnView.get_default ().newArticleList ();
		// });

		// var newest_first = new SettingSwitch (_ ("Oldest first"), Settings.general (), "articlelist-oldest-first");
		// newest_first.changed.connect ( () => {
		// 	ColumnView.get_default ().newArticleList ();
		// });

		// var scroll_marked = new SettingSwitch (_ ("Mark read by scrolling past"), Settings.general (), "articlelist-mark-scrolling");

		// var articleview_settings = headline (_ ("Article View:"));

		// var article_theme = new SettingDropbox (_ ("Theme"), Settings.general (), "article-theme", {_ ("Default"), _ ("Spring"), _ ("Midnight"), _ ("Parchment"), _ ("Gruvbox")});
		// article_theme.changed.connect ( () => {
		// 	ColumnView.get_default ().reloadArticleView ();
		// });

		// var fontfamilly = new SettingFont (_ ("Font Family"), Settings.general (), "font");
		// fontfamilly.changed.connect ( () => {
		// 	ColumnView.get_default ().reloadArticleView ();
		// });

		// var uiBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
		// uiBox.expand = true;
		// uiBox.pack_start (feed_settings, false, true, 0);
		// uiBox.pack_start (only_feeds, false, true, 0);
		// uiBox.pack_start (only_unread, false, true, 0);
		// uiBox.pack_start (feedlist_sort, false, true, 0);
		// // uiBox.pack_start (feedlist_theme, false, true, 0);
		// uiBox.pack_start (article_settings, false, true, 0);
		// uiBox.pack_start (article_sort, false, true, 0);
		// uiBox.pack_start (newest_first, false, true, 0);
		// uiBox.pack_start (scroll_marked, false, true, 0);
		// uiBox.pack_start (articleview_settings, false, true, 0);
		// uiBox.pack_start (article_theme, false, true, 0);
		// uiBox.pack_start (fontfamilly, false, true, 0);
		return interface_grid;
	}


	private Gtk.Grid setup_Internal () {
		var internal_grid = new Gtk.Grid () {
			column_spacing = 12,
			row_spacing = 6
		};

		var sync_count = new SettingsSpin (Settings.general (), "max-articles", 10, 5000, 10);

		var sync_time = new SettingsSpin (Settings.general (), "sync", 0, 600, 5);
		sync_time.spin_changed.connect (() => {
			FeedReaderBackend.get_default ().scheduleSync (Settings.general ().get_int ("sync"));
		});

		var drop_articles = new SettingsCombo (Settings.general (), "drop-articles-after",
		{_("Never"), _("1 Week"), _("1 Month"), _("6 Months")});
		drop_articles.combo_changed.connect (() => {
			Settings.state ().reset ("last-sync");
		});

		var grabber = new SettingsSwitch (Settings.general (), "content-grabber");

		var images = new SettingsSwitch (Settings.general (), "download-images");

		var mediaplayer = new SettingsSwitch (Settings.general (), "mediaplayer");

		internal_grid.attach (new Granite.HeaderLabel (_("Sync")), 0, 0, 3);
		internal_grid.attach (new SettingsLabel (_("Synced articles:")), 0, 1);
		internal_grid.attach (sync_count, 1, 1, 2);
		internal_grid.attach (new SettingsLabel (_("Sync interval:")), 0, 2);
		internal_grid.attach (sync_time, 1, 2);
		internal_grid.attach (new Granite.HeaderLabel (_("Database")), 0, 3, 3);
		internal_grid.attach (new SettingsLabel (_("Delete articles after:")), 0, 4);
		internal_grid.attach (drop_articles, 1, 4, 2);
		internal_grid.attach (new Granite.HeaderLabel (_("Additional Functionality")), 0, 5, 3);
		internal_grid.attach (new SettingsLabel (_("Download Full Text:")), 0, 6);
		internal_grid.attach (grabber, 1, 6);
		internal_grid.attach (new SettingsLabel (_("Download Images:")), 0, 7);
		internal_grid.attach (images, 1, 7);
		internal_grid.attach (new SettingsLabel (_("Internal Media Player:")), 0, 8);
		internal_grid.attach (mediaplayer, 1, 8);

		return internal_grid;
	}


	private Gtk.Box setup_Service () {
		m_serviceList = new Gtk.ListBox ();
		m_serviceList.set_selection_mode (Gtk.SelectionMode.NONE);
		m_serviceList.set_sort_func (sortFunc);

		m_errorBar = new InfoBar ("");

		var service_scroll = new Gtk.ScrolledWindow (null, null);
		service_scroll.expand = true;

		var overlay = new Gtk.Overlay ();
		overlay.add (service_scroll);
		overlay.add_overlay (m_errorBar);
		overlay.margin_top = 10;
		overlay.margin_bottom = 10;

		var viewport = new Gtk.Viewport (null, null);
		viewport.get_style_context ().add_class ("servicebox");
		viewport.add (m_serviceList);
		service_scroll.add (viewport);

		refreshAccounts ();

		var serviceBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);
		serviceBox.expand = true;
		serviceBox.pack_start (overlay, false, true, 0);

		return serviceBox;
	}

	public void refreshAccounts ()
	{
		m_serviceList.set_header_func (null);
		var children = m_serviceList.get_children ();
		foreach (Gtk.Widget row in children)
		{
			m_serviceList.remove (row);
			row.destroy ();
		}

		var list = Share.get_default ().getAccounts ();

		foreach (var account in list)
		{
			if (account.isSystemAccount ())
			{
				ServiceSetup row = Share.get_default ().newSystemAccount (account.getID ());
				m_serviceList.add (row);
				row.reveal (false);
			}
			else if (Share.get_default ().needSetup (account.getID ()))
			{
				ServiceSetup row = Share.get_default ().newSetup_withID (account.getID ());
				row.removeRow.connect ( () => {
					removeRow (row, m_serviceList);
				});
				m_serviceList.add (row);
				row.reveal (false);
			}
		}

		var addAccount = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.DND);
		addAccount.set_relief (Gtk.ReliefStyle.NONE);
		addAccount.get_style_context ().add_class ("addServiceButton");
		addAccount.set_size_request (0, 48);
		addAccount.show ();
		m_serviceList.add (addAccount);

		addAccount.clicked.connect ( () => {
			children = m_serviceList.get_children ();
			foreach (Gtk.Widget row in children)
			{
				var tmpRow = row as ServiceSetup;
				if (tmpRow != null && !tmpRow.isLoggedIn ())
				{
					Share.get_default ().refreshAccounts ();
					removeRow (tmpRow, m_serviceList);
				}
			}

			var popover = new ServiceSettingsPopover (addAccount);
			popover.newAccount.connect ( (type) => {
				ServiceSetup row = Share.get_default ().newSetup (type);
				row.showInfoBar.connect ( (text) => {
					m_errorBar.setText (text);
					m_errorBar.reveal ();
				});
				row.removeRow.connect ( () => {
					removeRow (row, m_serviceList);
				});
				m_serviceList.add (row);
				row.reveal ();
			});
		});

		m_serviceList.set_header_func (headerFunc);
	}

	public void removeRow (ServiceSetup row, Gtk.ListBox list)
	{
		row.unreveal ();
		GLib.Timeout.add (700,  () => {
			list.remove (row);
			return false;
		});
	}

	private int sortFunc (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2)
	{
		var r1 = row1 as ServiceSetup;
		var r2 = row2 as ServiceSetup;

		if (r1 == null && r2 == null)
		{
			return 0;
		}
		else if (r1 == null)
		{
			return 1;
		}
		else if (r2 == null)
		{
			return -1;
		}

		if (r1.getUserName () == ""
		&& r2.getUserName () == "")
		{
			return 0;
		}
		else if (r1.getUserName () == "")
		{
			return 1;
		}
		else if (r2.getUserName () == "")
		{
			return -1;
		}

		bool sys1 = r1.isSystemAccount ();
		bool sys2 = r2.isSystemAccount ();

		if (sys1 && sys2)
		{
			return 0;
		}
		else if (sys1)
		{
			return -1;
		}

		return 1;
	}

	private void headerFunc (Gtk.ListBoxRow row, Gtk.ListBoxRow? before)
	{
		var label = new Gtk.Label (_ ("System Accounts"));
		label.get_style_context ().add_class ("bold");
		label.margin_top = 20;
		label.margin_bottom = 5;

		var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		box.pack_start (label, true, true, 0);
		box.pack_end (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), false, false, 0);
		box.show_all ();

		var r1 = row as ServiceSetup;

		// this is the plus-button
		if (r1 == null)
		{
			return;
		}

		bool sys1 = r1.isSystemAccount ();

		if (before == null)
		{
			if (sys1)
			{
				row.set_header (box);
				return;
			}
			else
			{
				label.set_text (_ ("FeedReader Accounts"));
				row.set_header (box);
				return;
			}
		}


		var r2 = before as ServiceSetup;
		bool sys2 = r2.isSystemAccount ();

		if (r1 != null && r2 != null)
		{
			if (!sys1 && sys2)
			{
				label.set_text (_ ("FeedReader Accounts"));
				row.set_header (box);
			}
		}
	}

	private class SettingsLabel : Gtk.Label {
		public SettingsLabel (string text) {
	        label = text;
	        halign = Gtk.Align.END;
	        margin_start = 12;
	    }
	}

	private class SettingsSwitch : Gtk.Switch {
		public signal void changed ();

	    public SettingsSwitch (GLib.Settings settings, string key) {
	        halign = Gtk.Align.START;
	        valign = Gtk.Align.CENTER;
	        active = settings.get_boolean (key);

	        notify["active"].connect (() => {
	        	settings.set_boolean (key, this.active);
	        	changed ();
	        });
	    }
	}

	private class SettingsSpin : Gtk.SpinButton {
		public signal void spin_changed ();

		public SettingsSpin (GLib.Settings settings, string key, int min, int max, int step) {
			halign = Gtk.Align.START;
			valign = Gtk.Align.CENTER;
			value = settings.get_int (key);
			set_range (min, max);
			set_increments (step, 1);

			value_changed.connect (() => {
				settings.set_int (key, this.get_value_as_int ());
				spin_changed ();
			});
		}
	}

	private class SettingsCombo : Gtk.ComboBox {
		public signal void combo_changed ();

		public SettingsCombo (GLib.Settings settings, string key, string[] values, string? tooltip = null) {
			var liststore = new Gtk.ListStore (1, typeof (string));

			foreach (string val in values) {
				Gtk.TreeIter iter;
				liststore.append (out iter);
				liststore.set (iter, 0, val);
			}

			model = liststore;
			var renderer = new Gtk.CellRendererText ();
			pack_start (renderer, false);
			add_attribute (renderer, "text", 0);
			set_active (settings.get_enum (key));
			combo_changed.connect (() => {
				settings.set_enum (key, this.get_active ());
				combo_changed ();
			});
		}
	}

	private class SettingsFont : Gtk.FontButton {
		public signal void font_changed ();

		public SettingsFont (GLib.Settings settings, string key) {
			var current_font = settings.get_value (key).get_maybe ();
			if (current_font != null) {
				font = current_font.get_string ();
			}
			use_size = false;
			show_size = true;
			font_set.connect (() => {
				var new_font = new Variant.string (this.get_font_name ());
				settings.set_value (key, new Variant.maybe (VariantType.STRING, new_font));
			});
		}
	}

	private Gtk.Label headline (string name) {
		var headline = new Gtk.Label (name) {
			halign = Gtk.Align.START,
			xalign = 0
		};
		headline.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
		return headline;
	}
}
