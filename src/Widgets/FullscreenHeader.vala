/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2021 Your Name <singharajdeep97@gmail.com>
*/

public class FeedReader.FullscreenHeader : Gtk.EventBox {

	private Gtk.Revealer m_revealer;
	private ColumnViewHeader m_header;
	private bool m_hover = false;
	private bool m_popover = false;
	private uint m_timeout_source_id = 0;

	public FullscreenHeader () {
		var fullscreen_header = new Hdy.HeaderBar () {
			decoration_layout = ":maximize",
			show_close_button = true
		};
		fullscreen_header.get_style_context ().add_class ("titlebar");
		fullscreen_header.get_style_context ().add_class ("imageOverlay");

		var share_icon = new Gtk.Image.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
		var tag_icon = new Gtk.Image.from_icon_name ("tag", Gtk.IconSize.LARGE_TOOLBAR);
		var read_icon = new Gtk.Image.from_icon_name ("mail-read", Gtk.IconSize.LARGE_TOOLBAR);
		var unread_icon = new Gtk.Image.from_icon_name ("mail-unread", Gtk.IconSize.LARGE_TOOLBAR);

		var read_button = new HoverButton (read_icon, unread_icon, false, "r", _("Mark as unread"), _("Mark as read"));
		read_button.sensitive = false;
		read_button.clicked.connect (() => {
			ColumnView.get_default ().toggleReadSelectedArticle ();
		});

		var tag_button = new Gtk.Button ();
		tag_button.add (tag_icon);
		tag_button.set_focus_on_click (false);
		tag_button.set_tooltip_text (_("Tag article"));
		tag_button.sensitive = false;
		tag_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		tag_button.clicked.connect (() => {
			m_popover = true;
			var pop = new TagPopover (tag_button);
			pop.closed.connect ( () => {
				m_popover = false;
				if (!m_hover) {
					m_revealer.set_reveal_child (false);
				};
			});
		});

		m_header = new ColumnViewHeader ();
		m_header.fsClick.connect (() => {
			ColumnView.get_default ().showPane ();
			ColumnView.get_default ().leaveFullscreenArticle ();
			MainWindow.get_default ().unfullscreen ();
		});

		var print_button = new Gtk.Button ();
		print_button.image = new Gtk.Image.from_icon_name ("printer", Gtk.IconSize.LARGE_TOOLBAR);
		print_button.set_focus_on_click (false);
		print_button.set_tooltip_text (_("Print article"));
		print_button.sensitive = false;
		print_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		print_button.clicked.connect (() => {
			ColumnView.get_default ().print ();
		});

		var share_button = new Gtk.Button ();
		share_button.add (share_icon);
		share_button.set_relief (Gtk.ReliefStyle.NONE);
		share_button.set_focus_on_click (false);
		share_button.set_tooltip_text (_("Export or Share this article"));
		share_button.sensitive = false;

		share_button.clicked.connect ( () => {
			m_popover = true;
			var share_popover = new SharePopover (share_button);
			share_popover.closed.connect ( () => {
				share_popover = null;
				m_popover = false;
				if (!m_hover) {
					m_revealer.set_reveal_child (false);
				}
			});
		});

		var shortcut_button = new Gtk.Button();
		shortcut_button.image = new Gtk.Image.from_icon_name("preferences-desktop-keyboard", Gtk.IconSize.LARGE_TOOLBAR);
		shortcut_button.set_tooltip_text (_("Menu"));

		fullscreen_header.pack_start (read_button);
		fullscreen_header.pack_start (tag_button);
		fullscreen_header.pack_end (shortcut_button);
		fullscreen_header.pack_end (share_button);
		fullscreen_header.pack_end (print_button);

		m_revealer = new Gtk.Revealer ();
		m_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
		m_revealer.set_transition_duration (300);
		m_revealer.valign = Gtk.Align.START;
		m_revealer.add (fullscreen_header);

		this.set_size_request (0, 80);
		this.no_show_all = true;
		this.enter_notify_event.connect ( (event) => {
			m_revealer.set_transition_duration (300);
			m_revealer.show_all ();
			m_revealer.set_reveal_child (true);
			m_hover = true;
			removeTimeout ();
			return true;
		});
		this.leave_notify_event.connect ( (event) => {
			if (event.detail == Gdk.NotifyType.INFERIOR)
			{
				return false;
			}

			if (event.detail == Gdk.NotifyType.NONLINEAR_VIRTUAL)
			{
				return false;
			}

			m_hover = false;

			if (m_popover)
			{
				return false;
			}


			removeTimeout ();
			m_timeout_source_id = GLib.Timeout.add (500, () => {
				m_revealer.set_transition_duration (800);
				m_revealer.set_reveal_child (false);
				m_timeout_source_id = 0;
				return false;
			});

			return true;
		});
		this.add (m_revealer);
		this.valign = Gtk.Align.START;
	}

	public void setTitle (string title)
	{
		m_header.set_title (title);
	}

	public void setMarked (ArticleStatus marked)
	{
		m_header.setMarked (marked);
	}

	public void setRead (ArticleStatus read)
	{
		m_header.setRead (read);
	}

	private void removeTimeout ()
	{
		if (m_timeout_source_id > 0)
		{
			GLib.Source.remove (m_timeout_source_id);
			m_timeout_source_id = 0;
		}
	}

	public void showMediaButton (bool show)
	{
		m_header.showMediaButton (show);
	}
}
