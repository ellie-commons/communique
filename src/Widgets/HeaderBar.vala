/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Your Name <singharajdeep97@gmail.com>
 */

public class FeedReader.HeaderBar : Gtk.HeaderBar {
	private UpdateButton m_refresh_button;
	private Gtk.SearchEntry m_search;
	private Gtk.Button m_share_button;
	private Gtk.Button m_tag_button;
	private Gtk.Button m_print_button;
	private AttachedMediaButton m_media_button;
	private HoverButton m_mark_button;
	private HoverButton m_read_button;
	private Gtk.Button m_fullscreen_button;
	private Gtk.Button m_close_button;
	private SharePopover? m_sharePopover = null;

	public signal void refresh ();
	public signal void cancel ();
	public signal void search_term (string searchTerm);
	public signal void toggleMarked ();
	public signal void toggleRead ();
	public signal void closeArticle ();
	public signal void fsClick ();
	public signal void popClosed ();
	public signal void popOpened ();

	public HeaderBar (bool fullscreen) {
		Object (
			show_close_button: true
		);
	}

	construct {
		bool updating = Settings.state ().get_boolean ("currently-updating");

		m_refresh_button = new UpdateButton.from_icon_name ("view-refresh-symbolic", _ ("Update feeds"), "<Ctrl>r", true, true);
		m_refresh_button.updating (updating);
		m_refresh_button.clicked.connect (() => {
			if (!m_refresh_button.getStatus ()) {
				refresh ();
			}
			else {
				cancel ();
				m_refresh_button.setSensitive (false);
			}
		});

		m_search = new Gtk.SearchEntry ();
		m_search.placeholder_text = _ ("Search Articles");
		if (Settings.tweaks ().get_boolean ("restore-searchterm")) {
			m_search.text = Settings.state ().get_string ("search-term");
		}

		// connect after 160ms because Gtk.SearchEntry fires search_changed with 150ms delay
		// with the timeout the signal should not trigger a newList () when restoring the state at startup
		GLib.Timeout.add (160,  () => {
			m_search.search_changed.connect ( () => {
				search_term (m_search.text);
			});
			return false;
		});

		var share_icon = new Gtk.Image.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
		var tag_icon = new Gtk.Image.from_icon_name ("tag", Gtk.IconSize.LARGE_TOOLBAR);
		var marked_icon = new Gtk.Image.from_icon_name ("user-bookmarks", Gtk.IconSize.LARGE_TOOLBAR);
		var unmarked_icon = new Gtk.Image.from_icon_name ("bookmark-missing", Gtk.IconSize.LARGE_TOOLBAR);
		var read_icon = new Gtk.Image.from_icon_name ("mail-read", Gtk.IconSize.LARGE_TOOLBAR);
		var unread_icon = new Gtk.Image.from_icon_name ("mail-unread", Gtk.IconSize.LARGE_TOOLBAR);
		var fs_icon = new Gtk.Image.from_icon_name (fullscreen ? "view-restore" : "view-fullscreen", Gtk.IconSize.LARGE_TOOLBAR);
		var close_icon = new Gtk.Image.from_icon_name ("window-close-symbolic", Gtk.IconSize.LARGE_TOOLBAR);

		var menubutton = new Gtk.Button();
		menubutton.image = new Gtk.Image.from_icon_name("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
		// menubutton.set_use_popover(true);
		// menubutton.set_menu_model(Utils.getMenu());
		menubutton.set_tooltip_text (_("Menu"));

		var preferences_button = new Gtk.ModelButton () {
			text = _("Preferences"),
			margin_bottom = 6
		};

		var account_button = new Gtk.ModelButton () {
			text = _("Change Account..."),
			margin_top = 6
		};

		var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
			margin_top = 3,
			margin_bottom = 3
		};

		var grid = new Gtk.Grid () {
			orientation = Gtk.Orientation.VERTICAL
		};
		grid.add (account_button);
		grid.add (separator);
		grid.add (preferences_button);

		var popover = new Gtk.Popover (menubutton);
		popover.add (grid);

		menubutton.clicked.connect (() => {
			popover.show_all ();
		});

		preferences_button.button_release_event.connect (() => {
			SettingsDialog.get_default().showDialog("ui");
			popover.hide ();

			return Gdk.EVENT_STOP;
		});

		account_button.button_release_event.connect (() => {
			MainWindow.get_default ().setupResetPage ();
			popover.hide ();

			return Gdk.EVENT_STOP;
		});

		account_button.button_release_event.connect (() => {
			MainWindow.get_default ().setupResetPage();

		    return Gdk.EVENT_STOP;
		});

		m_mark_button = new HoverButton (unmarked_icon, marked_icon, false, "m", _("Star article"), _("Unstar article"));
		m_mark_button.sensitive = false;
		m_mark_button.clicked.connect ( () => {
			toggledMarked ();
		});
		m_read_button = new HoverButton (read_icon, unread_icon, false, "r", _("Mark as unread"), _("Mark as read"));
		m_read_button.sensitive = false;
		m_read_button.clicked.connect ( () => {
			toggledRead ();
		});

		m_fullscreen_button = new Gtk.Button ();
		m_fullscreen_button.add (fs_icon);
		m_fullscreen_button.set_focus_on_click (false);
		m_fullscreen_button.tooltip_markup = Granite.markup_accel_tooltip ({"F11"}, fullscreen ? _("Leave fullscreen mode") : _("Enter fullscreen mode"));
		m_fullscreen_button.sensitive = false;
		m_fullscreen_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		m_fullscreen_button.clicked.connect ( () => {
			fsClick ();
		});

		m_close_button = new Gtk.Button ();
		m_close_button.add (close_icon);
		m_close_button.set_focus_on_click (false);
		m_close_button.set_tooltip_text (_ ("Close article"));
		m_close_button.sensitive = false;
		m_close_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		m_close_button.clicked.connect ( () => {
			closeArticle ();
		});

		m_tag_button = new Gtk.Button ();
		m_tag_button.add (tag_icon);
		m_tag_button.set_focus_on_click (false);
		m_tag_button.set_tooltip_text (_ ("Tag article"));
		m_tag_button.sensitive = false;
		m_tag_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		m_tag_button.clicked.connect (() => {
			popOpened ();
			var pop = new TagPopover (m_tag_button);
			pop.closed.connect ( () => {
				popClosed ();
			});
		});


		m_print_button = new Gtk.Button ();
		m_print_button.image = new Gtk.Image.from_icon_name ("printer", Gtk.IconSize.LARGE_TOOLBAR);
		m_print_button.set_focus_on_click (false);
		m_print_button.set_tooltip_text (_ ("Print article"));
		m_print_button.sensitive = false;
		m_print_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		m_print_button.clicked.connect ( () => {
			ColumnView.get_default ().print ();
		});


		m_share_button = new Gtk.Button ();
		m_share_button.add (share_icon);
		m_share_button.set_relief (Gtk.ReliefStyle.NONE);
		m_share_button.set_focus_on_click (false);
		m_share_button.set_tooltip_text (_ ("Export or Share this article"));
		m_share_button.sensitive = false;

		var shareSpinner = new Gtk.Spinner ();
		var shareStack = new Gtk.Stack ();
		shareStack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
		shareStack.set_transition_duration (100);
		shareStack.add_named (m_share_button, "button");
		shareStack.add_named (shareSpinner, "spinner");
		shareStack.set_visible_child_name ("button");

		m_share_button.clicked.connect ( () => {
			popOpened ();
			m_sharePopover = new SharePopover (m_share_button);
			m_sharePopover.startShare.connect ( () => {
				shareStack.set_visible_child_name ("spinner");
				shareSpinner.start ();
			});
			m_sharePopover.shareDone.connect ( () => {
				shareStack.set_visible_child_name ("button");
				shareSpinner.stop ();
			});
			m_sharePopover.closed.connect ( () => {
				m_sharePopover = null;
				popClosed ();
			});
		});

		m_media_button = new AttachedMediaButton ();
		m_media_button.popOpened.connect ( () => {
			popOpened ();
		});
		m_media_button.popClosed.connect ( () => {
			popClosed ();
		});

		pack_start (m_refresh_button);
		pack_start (new Gtk.Grid ());
		pack_start (m_search);
	
	}

	public void setRefreshButton (bool status) {
		m_refresh_button.updating (status, false);
	}

	public void setButtonsSensitive (bool sensitive) {
		Logger.debug ("HeaderBar: setButtonsSensitive %s".printf (sensitive ? "true" : "false"));
		// m_modeButton.sensitive = sensitive;
		m_refresh_button.setSensitive (sensitive);
		m_search.sensitive = sensitive;
	}

	public bool searchFocused () {
		return m_search.has_focus;
	}

	public void updateSyncProgress (string progress) {
		m_refresh_button.setProgress (progress);
	}

	public void saveState (ref InterfaceState state) {
		state.setSearchTerm (m_search.text);
	}
}
