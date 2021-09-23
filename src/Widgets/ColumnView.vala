/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2021 Your Name <singharajdeep97@gmail.com>
*/

public class FeedReader.ColumnView : Gtk.Paned {

	private Gtk.Paned m_pane;
	private ModeButton m_mode_button;
	private ArticleListState m_state;
	private ArticleView m_article_view;
	private ArticleList m_articleList;
	private feedList m_feedList;
	private FeedListFooter m_footer;
	private ColumnViewHeader m_headerbar;

	public signal void change_state (ArticleListState state, Gtk.StackTransitionType transition);

	private static ColumnView? m_columnView = null;

	public static ColumnView get_default () {
		if (m_columnView == null) {
			m_columnView = new ColumnView ();
		}

		return m_columnView;
	}

	private ColumnView () {
		Logger.debug ("ColumnView: setup");
		m_feedList = new feedList ();
		m_footer = new FeedListFooter ();
		var feedListBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
			hexpand = true
		};
		feedListBox.pack_start (m_feedList);
		feedListBox.pack_end (m_footer, false, false);

		m_state = (ArticleListState)Settings.state ().get_enum ("show-articles");

		m_pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
		m_pane.set_size_request (0, 300);
		m_pane.set_position (Settings.state ().get_int ("feed-row-width"));
		m_pane.pack1 (feedListBox, false, false);

		var all_icon = new Gtk.Image.from_icon_name ("view-list-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
		all_icon.get_style_context ().add_class (Granite.STYLE_CLASS_ACCENT);

		var all_grid = new Gtk.Grid () {
			orientation = Gtk.Orientation.VERTICAL,
			halign = Gtk.Align.CENTER
		};
		all_grid.add (all_icon);
		all_grid.add (new Gtk.Label ("All"));

		var unread_icon = new Gtk.Image.from_icon_name ("mail-unread-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
		unread_icon.get_style_context ().add_class (Granite.STYLE_CLASS_ACCENT);

		var unread_grid = new Gtk.Grid () {
			orientation = Gtk.Orientation.VERTICAL,
			halign = Gtk.Align.CENTER
		};
		unread_grid.add (unread_icon);
		unread_grid.add (new Gtk.Label ("Unread"));

		var starred_grid = new Gtk.Grid () {
			orientation = Gtk.Orientation.VERTICAL,
			halign = Gtk.Align.CENTER
		};
		starred_grid.add (new Gtk.Image.from_icon_name ("starred-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
		starred_grid.add (new Gtk.Label ("Starred"));

		m_mode_button = new ModeButton();
		m_mode_button.append(all_grid, _("Show all articles"));
		m_mode_button.append(unread_grid, _("Show unread articles"));
		m_mode_button.append(starred_grid, _("Show starred articles"));
		m_mode_button.set_active(m_state, true);

		m_mode_button.mode_changed.connect(() => {
			var transition = Gtk.StackTransitionType.CROSSFADE;
			if(m_state == ArticleListState.ALL
			|| (ArticleListState)m_mode_button.selected == ArticleListState.MARKED) {
				transition = Gtk.StackTransitionType.SLIDE_LEFT;
				all_icon.get_style_context ().add_class ("active");
			}
			else if(m_state == ArticleListState.MARKED
			|| (ArticleListState)m_mode_button.selected == ArticleListState.ALL) {
				transition = Gtk.StackTransitionType.SLIDE_RIGHT;
			}

			m_state = (ArticleListState)m_mode_button.selected;
			change_state(m_state, transition);
		});

		m_feedList.clearSelected.connect (() => {
			m_footer.setRemoveButtonSensitive (false);
		});

		m_feedList.newFeedSelected.connect ((feedID) => {
			Logger.debug ("ContentPage: new Feed selected");
			m_articleList.setSelectedType (FeedListType.FEED);
			m_articleList.setSelectedFeed (feedID);
			newArticleList ();

			if (feedID == FeedID.ALL.to_string ()) {
				m_footer.setRemoveButtonSensitive (false);
			}
			else {
				m_footer.setRemoveButtonSensitive (true);
				m_footer.setSelectedRow (FeedListType.FEED, feedID);
			}
		});

		m_feedList.newTagSelected.connect ((tagID) => {
			Logger.debug ("ContentPage: new Tag selected");
			m_articleList.setSelectedType (FeedListType.TAG);
			m_articleList.setSelectedFeed (tagID);
			newArticleList ();
			m_footer.setRemoveButtonSensitive (true);
			m_footer.setSelectedRow (FeedListType.TAG, tagID);
		});

		m_feedList.newCategorieSelected.connect ((categorieID) => {
			Logger.debug ("ContentPage: new Category selected");
			m_articleList.setSelectedType (FeedListType.CATEGORY);
			m_articleList.setSelectedFeed (categorieID);
			newArticleList ();

			if (categorieID != CategoryID.MASTER.to_string ()
			&& categorieID != CategoryID.TAGS.to_string ()) {
				m_footer.setRemoveButtonSensitive (true);
				m_footer.setSelectedRow (FeedListType.CATEGORY, categorieID);
			}
			else {
				m_footer.setRemoveButtonSensitive (false);
			}
		});

		m_feedList.markAllArticlesAsRead.connect (markAllArticlesAsRead);


		m_articleList = new ArticleList () {
			vexpand = true
		};
		m_articleList.drag_begin.connect ((context) => {
			if (DataBase.readOnly ().read_tags ().is_empty) {
				m_feedList.newFeedlist (m_articleList.getState (), false, true);
			}
			m_feedList.expand_collapse_category (CategoryID.TAGS.to_string (), true);
			m_feedList.expand_collapse_category (CategoryID.MASTER.to_string (), false);
			m_feedList.addEmptyTagRow ();
		});
		m_articleList.drag_end.connect ((context) => {
			Logger.debug ("ContentPage: articleList drag_end signal");
			m_feedList.expand_collapse_category (CategoryID.MASTER.to_string (), true);
		});
		m_articleList.drag_failed.connect ((context, result) => {
			Logger.debug ("ContentPage: articleList drag_failed signal");
			if (DataBase.readOnly ().read_tags ().is_empty) {
				m_feedList.newFeedlist (m_articleList.getState (), false, false);
			}
			else {
				m_feedList.removeEmptyTagRow ();
			}
			return false;
		});
		setArticleListState ((ArticleListState)Settings.state ().get_enum ("show-articles"));

		var grid = new Gtk.Grid () {
			orientation = Gtk.Orientation.VERTICAL,
			vexpand = true
		};
		grid.add (m_articleList);
		grid.add (m_mode_button);

		m_pane.pack2 (grid, false, false);


		m_articleList.row_activated.connect ((row) => {
			if (m_article_view.getCurrentArticle () != row.getID ())
			{
				m_article_view.load (row.getID ());
				m_headerbar.showArticleButtons (true);
				m_headerbar.setTitle (row.getName ());
				Logger.debug ("ContentPage: set headerbar");
				m_headerbar.setRead (row.getArticle ().getUnread ());
				m_headerbar.setMarked (row.getArticle ().getMarked ());
				m_headerbar.showMediaButton (row.haveMedia ());
				m_article_view.showMediaButton (row.haveMedia ());
			}
		});

		m_article_view = new ArticleView ();


		this.orientation = Gtk.Orientation.HORIZONTAL;
		this.set_position (Settings.state ().get_int ("feeds-and-articles-width"));
		this.pack1 (m_pane, false, false);
		this.pack2 (m_article_view, true, false);
		// this.notify["position"].connect (() => {
		// 	m_headerbar.set_position (this.get_position ());
		// });

		m_headerbar = new ColumnViewHeader ();
		m_headerbar.refresh.connect (() => {
			syncStarted ();
			var app = FeedReaderApp.get_default ();
			app.sync ();
		});

		m_headerbar.cancel.connect (() => {
			FeedReaderApp.get_default ().cancelSync ();
		});

		change_state.connect ((state, transition) => {
			setArticleListState (state);
			newArticleList (transition);
		});

		m_headerbar.search_term.connect ((searchTerm) => {
			Logger.debug ("MainWindow: new search term");
			setSearchTerm (searchTerm);
			newArticleList ();
		});

		// m_headerbar.notify["position"].connect (() => {
		// 	this.set_position (m_headerbar.get_position ());
		// });

		m_headerbar.toggledMarked.connect (() => {
			toggleMarkedSelectedArticle ();
		});

		m_headerbar.toggledRead.connect (() => {
			toggleReadSelectedArticle ();
		});

		m_headerbar.closeArticle.connect (() => {
			clearArticleView ();
		});

		m_headerbar.size_allocate.connect (() => {
			m_headerbar.set_paned_positions (m_pane.position, this.position);
		});

		this.notify["position"].connect (() => {
			m_headerbar.set_paned_positions (m_pane.position, this.position, false);
		});

		m_pane.notify["position"].connect_after (() => {
			m_headerbar.set_paned_positions (m_pane.position, this.position);
		});
	}

	public void hidePane () {
		m_pane.set_visible (false);
	}

	public void showPane () {
		m_pane.set_visible (true);
	}

	public int ArticleListNEXT () {
		if (m_article_view.fullscreenArticle ()) {
			m_article_view.setTransition (Gtk.StackTransitionType.SLIDE_LEFT, 500);
		}

		return m_articleList.move (false);
	}

	public int ArticleListPREV () {
		if (m_article_view.fullscreenArticle ()) {
			m_article_view.setTransition (Gtk.StackTransitionType.SLIDE_RIGHT, 500);
		}

		return m_articleList.move (true);
	}

	public void FeedListNEXT () {
		m_feedList.move (false);
	}

	public void FeedListPREV () {
		m_feedList.move (true);
	}

	public void newArticleList (Gtk.StackTransitionType transition = Gtk.StackTransitionType.CROSSFADE) {
		Logger.debug ("ContentPage.newArticleList");
		int height = m_articleList.get_allocated_height ();
		if (height == 1) {
			ulong id = 0;
			id = m_articleList.draw.connect_after (() => {
				m_articleList.newList (transition);
				m_articleList.disconnect (id);
				return false;
			});
		}
		else {
			m_articleList.newList (transition);
		}
	}

	public void newFeedList (bool defaultSettings = false) {
		m_feedList.newFeedlist (m_articleList.getState (), defaultSettings);
	}

	public void refreshFeedListCounter () {
		m_feedList.refreshCounters (m_articleList.getState ());
	}

	public void reloadArticleView () {
		m_article_view.load ();
	}

	public void updateArticleList () {
		m_articleList.updateArticleList ();
	}

	private void setArticleListState (ArticleListState state) {
		var oldState = m_articleList.getState ();
		m_articleList.setState (state);

		if (oldState == ArticleListState.MARKED
		|| state == ArticleListState.MARKED) {
			m_feedList.refreshCounters (state);
		}
	}

	private void setSearchTerm (string searchTerm) {
		m_articleList.setSearchTerm (searchTerm);
		m_article_view.setSearchTerm (searchTerm);
	}

	private void clearArticleView () {
		m_headerbar.showArticleButtons (false);
		m_headerbar.clearTitle ();
		m_article_view.clearContent ();
	}

	public string getSelectedFeedListRow () {
		return m_feedList.getSelectedRow ();
	}

	public Article getSelectedArticle () {
		return m_articleList.getSelectedArticle ();
	}

	public void markAllArticlesAsRead () {
		m_headerbar.setRead (ArticleStatus.READ);
		m_articleList.markAllAsRead ();
	}

	public void toggleReadSelectedArticle () {
		m_headerbar.toggleRead ();
		m_article_view.setRead (m_articleList.toggleReadSelected ());
	}

	public void toggleMarkedSelectedArticle () {
		m_headerbar.toggleMarked ();
		m_article_view.setMarked (m_articleList.toggleMarkedSelected ());
	}

	public void openSelectedArticle () {
		m_articleList.openSelected ();
	}

	public void centerSelectedRow () {
		m_articleList.centerSelectedRow ();
	}

	public void removeTagFromSelectedRow (string tagID) {
		m_articleList.removeTagFromSelectedRow (tagID);
	}

	public void syncStarted () {
		m_articleList.syncStarted ();
	}

	public void syncFinished () {
		m_articleList.syncFinished ();
	}

	public Gdk.RGBA getBackgroundColor () {
		return m_articleList.getBackgroundColor ();
	}

	public void showArticleListOverlay () {
		m_articleList.showOverlay ();
	}

	public void setOffline () {
		m_headerbar.setOffline ();
		m_feedList.setOffline ();

		if (!Utils.canManipulateContent (false)) {
			m_footer.setAddButtonSensitive (false);
			m_feedList.newFeedlist (m_articleList.getState (), false);
		}
	}

	public void setOnline () {
		m_headerbar.setOnline ();
		m_feedList.setOnline ();

		if (Utils.canManipulateContent (true)) {
			m_footer.setAddButtonSensitive (true);
			m_feedList.newFeedlist (m_articleList.getState (), false);

			var selected_row = m_feedList.getSelectedRow ();
			string[] selected = selected_row.split (" ");

			if ((selected[0] == "feed" && selected[1] == FeedID.ALL.to_string ())
			||  (selected[0] == "cat" &&  (selected[1] == CategoryID.MASTER.to_string () || selected[1] == CategoryID.TAGS.to_string ()))) {
				m_footer.setRemoveButtonSensitive (false);
			}
		}
	}

	public void footerSetBusy () {
		m_footer.setBusy ();
	}

	public void footerSetReady () {
		m_footer.setReady ();
	}

	public void footerShowError (string errmsg) {
		m_footer.showError (errmsg);
	}

	public feedList getFeedList () {
		return m_feedList;
	}

	public void enterFullscreenArticle () {
		m_article_view.enterFullscreenArticle ();
	}

	public void leaveFullscreenArticle () {
		m_article_view.leaveFullscreenArticle ();
	}

	public bool isFullscreen () {
		return m_article_view.fullscreenArticle ();
	}

	public void exitFullscreenVideo () {
		m_article_view.exitFullscreenVideo ();
	}

	public bool isFullscreenVideo () {
		return m_article_view.fullscreenVideo ();
	}

	public bool ArticleListSelectedIsFirst () {
		return m_articleList.selectedIsFirst ();
	}

	public bool ArticleListSelectedIsLast () {
		return m_articleList.selectedIsLast ();
	}

	public void ArticleViewAddMedia (MediaPlayer media) {
		m_article_view.addMedia (media);
	}

	public void articleViewKillMedia () {
		m_article_view.killMedia ();
	}

	public void print () {
		m_article_view.print ();
	}

	public bool playingMedia () {
		return m_article_view.playingMedia ();
	}

	public string? displayedArticle () {
		return m_article_view.getCurrentArticle ();
	}

	public void saveState (ref InterfaceState state) {
		int offset = 0;
		double scrollPos = 0.0;
		m_articleList.getSavedState (out scrollPos, out offset);

		state.setArticleListScrollPos (scrollPos);
		state.setArticleListRowOffset (offset);
		state.setArticleListState(m_state);
		state.setFeedListSelectedRow (m_feedList.getSelectedRow ());
		state.setExpandedCategories (m_feedList.getExpandedCategories ());
		state.setFeedsAndArticleWidth (this.get_position ());
		state.setFeedListWidth (m_pane.get_position ());
		state.setFeedListScrollPos (m_feedList.vadjustment.value);
		state.setArticleViewScrollPos (m_article_view.getScrollPos ());
		var selectedArticle = m_articleList.getSelectedArticle ();
		if (selectedArticle != null)
		{
			state.setArticleListSelectedRow (selectedArticle.getArticleID ());
		}
		state.setArticleListTopRow (m_articleList.getFirstArticle ());

		m_headerbar.saveState (ref state);
	}

	public bool searchFocused () {
		return m_headerbar.searchFocused ();
	}

	public ColumnViewHeader getHeader () {
		return m_headerbar;
	}

	public void ArticleViewSendEvent (Gdk.EventKey event) {
		m_article_view.sendEvent (event);
	}

	public void clear () {
		m_articleList.clear ();
		clearArticleView ();
		m_feedList.clear ();
	}
}
