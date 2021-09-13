/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2021 Your Name <singharajdeep97@gmail.com>
*/

public class FeedReader.TagRow : Gtk.ListBoxRow {

	private Gtk.Box m_box;
	private Gtk.Label m_label;
	private bool m_exits;
	private string m_catID;
	private Gtk.Menu menu = null;
	private ColorCircle m_circle;
	private ColorPopover m_pop;
	private Gtk.Revealer m_revealer;
	private Gtk.EventBox m_eventBox;
	public string m_name;
	public Tag m_tag;
	public signal void moveUP ();
	public signal void removeRow ();

	public TagRow (Tag tag) {
		m_tag = tag;
		m_exits = true;
		m_name = m_tag.getTitle ().replace ("&","&amp;");
		m_catID = CategoryID.TAGS.to_string ();

		var rowhight = 30;
		m_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

		m_circle = new ColorCircle (m_tag.getColor ());
		m_circle.margin_start = 24;
		m_pop = new ColorPopover (m_circle);

		m_circle.clicked.connect ((color) => {
			m_pop.show_all ();
		});

		m_pop.newColorSelected.connect ((color) => {
			m_circle.newColor (color);
			m_tag.setColor (color);
			FeedReaderBackend.get_default ().updateTagColor (m_tag);
		});

		m_label = new Gtk.Label (m_name);
		m_label.set_use_markup (true);
		m_label.set_size_request (0, rowhight);
		m_label.set_ellipsize (Pango.EllipsizeMode.END);
		m_label.set_alignment (0, 0.5f);

		m_box.pack_start (m_circle, false, false, 8);
		m_box.pack_start (m_label, true, true, 0);

		m_revealer = new Gtk.Revealer ();
		m_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
		m_revealer.add (m_box);
		m_revealer.set_reveal_child (false);

		m_eventBox = new Gtk.EventBox ();
		m_eventBox.set_events (Gdk.EventMask.BUTTON_PRESS_MASK);
		m_eventBox.button_press_event.connect (onClick);
		m_eventBox.add (m_revealer);

		this.add (m_eventBox);
		this.show_all ();

		if (Utils.canManipulateContent ()) {
			const Gtk.TargetEntry[] accepted_targets = {
				{ "STRING",     0, DragTarget.TAG }
			};

			Gtk.drag_dest_set (
				this,
				Gtk.DestDefaults.MOTION,
				accepted_targets,
				Gdk.DragAction.COPY
			);

			this.drag_motion.connect (onDragMotion);
			this.drag_leave.connect (onDragLeave);
			this.drag_drop.connect (onDragDrop);
			this.drag_data_received.connect (onDragDataReceived);
		}
	}

	private bool onDragMotion (Gtk.Widget widget, Gdk.DragContext context, int x, int y, uint time) {
		this.set_state_flags (Gtk.StateFlags.PRELIGHT, false);
		return false;
	}

	private void onDragLeave (Gtk.Widget widget, Gdk.DragContext context, uint time) {
		this.unset_state_flags (Gtk.StateFlags.PRELIGHT);
	}

	private bool onDragDrop (Gtk.Widget widget, Gdk.DragContext context, int x, int y, uint time) {
		// If the source offers a target
		if (context.list_targets () != null) {
			var target_type =  (Gdk.Atom)context.list_targets ().nth_data (0);

			// Request the data from the source.
			Gtk.drag_get_data (widget, context, target_type, time);
			return true;
		}

		return false;
	}

	private void onDragDataReceived (Gtk.Widget widget, Gdk.DragContext context, int x, int y,
	Gtk.SelectionData selection_data, uint target_type, uint time) {
		if (selection_data != null
			&& selection_data.get_length () >= 0
		&& target_type == DragTarget.TAG) {
			string articleID =  (string)selection_data.get_data ();
			Article article = DataBase.readOnly ().read_article (articleID);
			Logger.debug (@"drag articleID: $articleID");

			if (m_tag.getTagID () != TagID.NEW) {
				FeedReaderBackend.get_default ().tagArticle (article, m_tag, true);
				Gtk.drag_finish (context, true, false, time);
			} else {
				showRenamePopover (context, time, article);
			}
		}
	}

	private bool onClick (Gdk.EventButton event) {
		// only right click allowed
		if (event.button != 3) {
			return false;
		}

		if (!Utils.canManipulateContent ()) {
			return false;
		}

		switch (event.type) {
			case Gdk.EventType.BUTTON_RELEASE:
			case Gdk.EventType.@2BUTTON_PRESS:
			case Gdk.EventType.@3BUTTON_PRESS:
			return false;
		}

		var rename_tag_menuitem = new Gtk.MenuItem.with_label (_("Rename Tag"));

		var delete_tag_menuitem = new Gtk.MenuItem.with_label (_("Remove Tag"));
		delete_tag_menuitem.activate.connect (() => {
			if (this.is_selected ()) {
				moveUP ();
			}

			uint time = 300;
			this.reveal (false, time);

			string text = _("Tag \"%s\" removed").printf (m_name);
			var notification = MainWindow.get_default ().showNotification (text);
			ulong eventID = notification.dismissed.connect ( () => {
				Logger.debug ("TagRow: delete Tag");
				FeedReaderBackend.get_default ().deleteTag (m_tag);
			});
			notification.action.connect ( () => {
				notification.disconnect (eventID);
				this.reveal (true, time);
				notification.dismiss ();
			});
		});

		menu = new Gtk.Menu ();
		menu.append (rename_tag_menuitem);
		menu.append (delete_tag_menuitem);

		menu.show_all ();
		menu.popup_at_pointer (null);

		rename_tag_menuitem.activate.connect (() => {
			menu.hide ();
			showRenamePopover ();
		});

		return true;
	}

	public void update (string name) {
		m_label.set_text (name.replace ("&","&amp;"));
		m_label.set_use_markup (true);
	}

	public Tag getTag () {
		return m_tag;
	}

	public void setExits (bool subscribed) {
		m_exits = subscribed;
	}

	public bool stillExits () {
		return m_exits;
	}

	public bool isRevealed () {
		return m_revealer.get_reveal_child ();
	}

	public void reveal (bool reveal, uint duration = 500) {
		m_revealer.set_transition_duration (duration);
		m_revealer.set_reveal_child (reveal);
	}

	private void showRenamePopover (Gdk.DragContext? context = null, uint time = 0, Article? article = null) {
		var popRename = new Gtk.Popover (this);
		popRename.set_position (Gtk.PositionType.BOTTOM);
		popRename.closed.connect ( () => {
			this.unset_state_flags (Gtk.StateFlags.PRELIGHT);
			if (m_tag.getTagID () == TagID.NEW && context != null) {
				Logger.debug ("TagRow: cancel drag");
				Gtk.drag_finish (context, false, false, time);
			}
		});

		var renameEntry = new Gtk.Entry ();
		renameEntry.set_text (m_name);
		renameEntry.activate.connect ( () => {
			if (m_tag.getTagID () != TagID.NEW) {
				popRename.hide ();
				m_tag = FeedReaderBackend.get_default ().renameTag (m_tag, renameEntry.get_text ());
			} else if (context != null) {
				m_tag = FeedReaderBackend.get_default ().createTag (renameEntry.get_text ());
				popRename.hide ();
				FeedReaderBackend.get_default ().tagArticle (article, m_tag, true);
				Gtk.drag_finish (context, true, false, time);
			}
		});

		string label = _ ("rename");
		if (m_tag.getTagID () == TagID.NEW && context != null) {
			label = _ ("add");
		}

		var renameButton = new Gtk.Button.with_label (label);
		renameButton.get_style_context ().add_class ("suggested-action");
		renameButton.clicked.connect ( () => {
			renameEntry.activate ();
		});

		var renameBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
		renameBox.margin = 5;
		renameBox.pack_start (renameEntry, true, true, 0);
		renameBox.pack_start (renameButton, false, false, 0);

		popRename.add (renameBox);
		popRename.show_all ();
		this.set_state_flags (Gtk.StateFlags.PRELIGHT, false);
	}
}
