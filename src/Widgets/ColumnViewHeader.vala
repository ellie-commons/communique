/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2021 Your Name <singharajdeep97@gmail.com>
*/

public class FeedReader.ColumnViewHeader : Hdy.HeaderBar {

	private UpdateButton m_refresh_button;
	private Gtk.SearchEntry m_search;
	private Gtk.Button m_share_button;
	private Gtk.Button m_tag_button;
	private Gtk.Button m_print_button;
	private HoverButton m_mark_button;
	private HoverButton m_read_button;
	private Gtk.Button m_close_button;
	private SharePopover? m_sharePopover = null;
	public Gtk.Grid spacing_widget;

	public signal void refresh ();
	public signal void cancel ();
	public signal void search_term (string searchTerm);
	public signal void toggledMarked ();
	public signal void toggledRead ();
	public signal void closeArticle ();
	public signal void popClosed ();
	public signal void popOpened ();

	static construct {
	  Hdy.init ();
	}

	public ColumnViewHeader () {
	    hexpand = true;
		custom_title = new Gtk.Grid ();
	    // orientation = Gtk.Orientation.HORIZONTAL;
	    show_close_button = true;

		bool updating = Settings.state ().get_boolean ("currently-updating");
		m_refresh_button = new UpdateButton.from_icon_name ("view-refresh-symbolic", _("Update feeds"), "<Ctrl>r", true, true);
		m_refresh_button.updating (updating);
		m_refresh_button.clicked.connect ( () => {
			if (!m_refresh_button.getStatus ()) {
				refresh ();
			}
			else {
				cancel ();
				m_refresh_button.setSensitive (false);
			}
		});

		m_search = new Gtk.SearchEntry () {
			margin_start = 5
		};
		m_search.placeholder_text = _("Search Articles");
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

		spacing_widget = new Gtk.Grid ();

		// m_header_left = new Gtk.HeaderBar () {
		// 	hexpand = true
		// };

		var share_icon = new Gtk.Image.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
		var tag_icon = new Gtk.Image.from_icon_name ("tag", Gtk.IconSize.LARGE_TOOLBAR);
		var marked_icon = new Gtk.Image.from_icon_name ("user-bookmarks", Gtk.IconSize.LARGE_TOOLBAR);
		var unmarked_icon = new Gtk.Image.from_icon_name ("bookmark-missing", Gtk.IconSize.LARGE_TOOLBAR);
		var read_icon = new Gtk.Image.from_icon_name ("mail-read", Gtk.IconSize.LARGE_TOOLBAR);
		var unread_icon = new Gtk.Image.from_icon_name ("mail-unread", Gtk.IconSize.LARGE_TOOLBAR);
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

		var shortcuts_button = new Gtk.ModelButton () {
		    text = _("Shortcuts")
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
		grid.add (shortcuts_button);
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

		shortcuts_button.button_release_event.connect (() => {
			new Shortcuts ();
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

		var search_grid = new Gtk.Grid () {
			valign = Gtk.Align.CENTER
		};
		search_grid.add (m_search);

		this.pack_start (m_refresh_button);
		this.pack_start (spacing_widget);
		this.pack_start (search_grid);
		this.pack_start (m_read_button);
		// this.pack_start (m_mark_button);
		this.pack_start (m_tag_button);
		this.pack_end (menubutton);
		this.pack_end (shareStack);
		this.pack_end (m_print_button);
		this.pack_end (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
		this.pack_end (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
	}

	public void set_paned_positions (int start_position, int end_position, bool start_changed = true) {
    m_search.width_request = end_position - start_position;
    	if (start_changed) {
        	int spacing_position;
        	child_get (spacing_widget, "position", out spacing_position, null);
        	var style_context = get_style_context ();
        	// The left padding between the window and the headerbar widget
        	int offset = style_context.get_padding (style_context.get_state ()).left;
        	forall ((widget) => {
        	    if (widget == custom_title || widget.get_style_context ().has_class ("right")) {
        	        return;
        	    }

        	    int widget_position;
        	    child_get (widget, "position", out widget_position, null);
        	    if (widget_position < spacing_position) {
        	        offset += widget.get_allocated_width () + spacing;
        	    }
        	});

        	offset += spacing;
        	spacing_widget.width_request = start_position - int.min (offset, start_position);
    	}
    }

	public void showArticleButtons (bool show) {
		Logger.debug ("HeaderBar: showArticleButtons %s".printf (sensitive ? "true" : "false"));
		m_mark_button.sensitive = show;
		m_read_button.sensitive = show;
		m_close_button.sensitive = show;
		m_share_button.sensitive =  (show && FeedReaderApp.get_default ().isOnline ());
		m_print_button.sensitive = show;

		if (FeedReaderBackend.get_default ().supportTags ()
		&& Utils.canManipulateContent ()) {
			m_tag_button.sensitive =  (show && FeedReaderApp.get_default ().isOnline ());
		}
	}

	public void setMarked (ArticleStatus marked) {
		switch (marked) {
			case ArticleStatus.MARKED:
			// m_mark_button.setActive (true);
			break;
			case ArticleStatus.UNMARKED:
			default:
			m_read_button.setActive (false);
			break;
		}
	}

	// public void toggleMarked () {
	// 	m_mark_button.toggle ();
	// }

	public void setRead (ArticleStatus read) {
		switch (read) {
			case ArticleStatus.UNREAD:
			m_read_button.setActive (true);
			break;
			case ArticleStatus.READ:
			default:
			m_read_button.setActive (false);
			break;
		}
	}

	public void toggleRead () {
		m_read_button.toggle ();
	}

	public void setOffline () {
		m_share_button.sensitive = false;
		if (Utils.canManipulateContent ()
		&& FeedReaderBackend.get_default ().supportTags ()) {
			m_tag_button.sensitive = false;
		}
	}

	public void setOnline () {
		if (m_mark_button.sensitive) {
			m_share_button.sensitive = true;
			if (Utils.canManipulateContent ()
			&& FeedReaderBackend.get_default ().supportTags ()) {
				m_tag_button.sensitive = true;
			}
		}
	}

	public void refreshSahrePopover () {
		if (m_sharePopover == null) {
			return;
		}

		m_sharePopover.refreshList ();
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

	// public void showArticleButtons (bool show) {
	// 	showArticleButtons (show);
	// }

	public bool searchFocused () {
		return m_search.has_focus;
	}

	// public void setMarked (ArticleStatus marked) {
	// 	m_header_right.setMarked (marked);
	// }

	public void toggleMarked () {
		toggleMarked ();
	}

	// public void setRead (ArticleStatus read) {
	// 	m_header_right.setRead (read);
	// }

	// public void toggleRead () {
	// 	m_header_right.toggleRead ();
	// }

	public void focusSearch () {
		m_search.grab_focus ();
	}

	// public void setOffline () {
	// 	m_header_right.setOffline ();
	// }

	// public void setOnline () {
	// 	m_header_right.setOnline ();
	// }

	// public void showMediaButton (bool show) {
	// 	m_header_right.showMediaButton (show);
	// }

	public void updateSyncProgress (string progress) {
		m_refresh_button.setProgress (progress);
	}

	// public void refreshSahrePopover () {
	// 	m_header_right.refreshSahrePopover ();
	// }

	public void saveState (ref InterfaceState state) {
		state.setSearchTerm (m_search.text);
		// state.setArticleListState (m_state);
	}
	public void setTitle (string title) {
		set_title (title);
	}
	public void clearTitle () {
		set_title ("Communique");
	}
}
