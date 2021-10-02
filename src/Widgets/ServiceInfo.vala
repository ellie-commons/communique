/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2021 Your Name <singharajdeep97@gmail.com>
*/

public class FeedReader.ServiceInfo : Gtk.Overlay {
	private Gtk.Stack m_stack;
	private Gtk.Spinner m_spinner;
	private Gtk.Image m_logo;
	private Gtk.Label m_label;
	private Gtk.Label m_offline;
	private Gtk.Grid m_box;

	public ServiceInfo () {
		m_logo = new Gtk.Image.from_file ("");
		m_label = new Gtk.Label ("") {
			halign = Gtk.Align.CENTER,
			margin_start = 10,
			margin_end = 10,
			margin_top = 6
		};
		m_label.set_ellipsize (Pango.EllipsizeMode.END);
		m_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
		m_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

		m_box = new Gtk.Grid () {
			orientation = Gtk.Orientation.VERTICAL,
			hexpand = true,
			halign = Gtk.Align.CENTER,
			valign = Gtk.Align.CENTER
		};
		m_box.add (m_logo);
		m_box.add (m_label);
		m_box.margin_top = 20;
		m_box.margin_bottom = 5;

		m_spinner = new Gtk.Spinner ();

		m_stack = new Gtk.Stack ();
		m_stack.add_named (m_box, "info");
		m_stack.add_named (m_spinner, "spinner");
		m_stack.get_style_context ().add_class (Gtk.STYLE_CLASS_SIDEBAR);
		this.add (m_stack);

		m_offline = new Gtk.Label ("OFFLINE");
		m_offline.margin_start = 40;
		m_offline.margin_end = 40;
		m_offline.margin_top = 30;
		m_offline.margin_bottom = 10;
		// m_offline.get_style_context ().add_class ("osd");
		m_offline.no_show_all = true;
		this.add_overlay (m_offline);
	}

	public void refresh () {
		string? service_icon = FeedReaderBackend.get_default ().symbolicIcon ();
		string? user_name = FeedReaderBackend.get_default ().accountName ();
		string? server = FeedReaderBackend.get_default ().getServerURL ();

		if (this.is_visible ()) {
			if (user_name == "none" || service_icon == "none") {
				m_spinner.start ();
				m_stack.set_visible_child_name ("spinner");
			}
			else {
				m_logo.set_from_icon_name (service_icon, Gtk.IconSize.BUTTON);
				m_label.set_label (user_name);
				m_stack.set_visible_child_name ("info");
				if (server != "none") {
					this.set_tooltip_text (Utils.shortenURL (server));
				}
			}
		}

		show_all ();
	}

	public void setOffline () {
		m_offline.show ();
	}

	public void setOnline () {
		m_offline.hide ();
	}
}
