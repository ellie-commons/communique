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

public class FeedReader.SharePopover : Gtk.Popover {

	private Gtk.Grid main_grid;
	private Gtk.Stack m_stack;
	public signal void startShare ();
	public signal void shareDone ();

	public SharePopover (Gtk.Widget widget) {
		main_grid = new Gtk.Grid () {
			orientation = Gtk.Orientation.VERTICAL,
			margin_top = 3,
			margin_bottom = 3
		};
		refreshList ();
		m_stack = new Gtk.Stack ();
		m_stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
		m_stack.add (main_grid);

		this.add (m_stack);
		this.set_modal (true);
		this.set_relative_to (widget);
		this.set_position (Gtk.PositionType.BOTTOM);
		this.show_all ();
	}

	public void refreshList () {
		var children = main_grid.get_children ();

		foreach (Gtk.Widget row in children) {
			main_grid.remove (row);
			row.destroy ();
		}

		var list = Share.get_default ().getAccounts ();

		foreach (var account in list) {
			var share_button = new ShareRow (account.getType (), account.getID (), account.getUsername (), account.getIconName ());
			main_grid.add (share_button);
			share_button.clicked.connect (clicked);
		}

		var add_button = new Gtk.ModelButton () {
			text = _("Add Accounts...")
		};

		add_button.button_release_event.connect (() => {
			SettingsDialog.get_default ().showDialog ("service");
			Logger.debug ("SharePopover: open Settings");
			this.hide ();

			return Gdk.EVENT_STOP;
		});

		var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
			margin_top = 3,
			margin_bottom = 3
		};

		main_grid.add (separator);

		main_grid.add (add_button);

		add_button.show_all ();
		// main_grid.add (add_button);
	}

	private void clicked (Gtk.Button row) {
		ShareRow? shareRow = row as ShareRow;

		string id = shareRow.getID ();
		Article? selectedArticle = ColumnView.get_default ().getSelectedArticle ();

		if (selectedArticle != null) {
			var widget = Share.get_default ().shareWidget (shareRow.getType (), selectedArticle.getURL ());
			if (widget == null) {
				shareURL (id, selectedArticle.getURL ());
			} else {
				m_stack.add (widget);
				m_stack.set_visible_child (widget);
				widget.share.connect_after ( () => {
					shareURL (id, selectedArticle.getURL ());
				});
				widget.goBack.connect ( () => {
					m_stack.set_visible_child (main_grid);
					m_stack.remove (widget);
				});
			}
		}

	}

	private void shareInternal (string id, string url) {
		Share.get_default ().addBookmark (id, url);
	}

	private void shareURL (string id, string url) {
		this.hide ();
		startShare ();
		shareInternal (id, url);
		string idString =  (id == null || id == "") ? "" : @" to $id";
		Logger.debug (@"bookmark: $url$idString");
		shareDone ();
	}
}

public class FeedReader.ShareForm : Gtk.Box {

	public signal void share ();
	public signal void goBack ();

	public ShareForm () {

	}
}
