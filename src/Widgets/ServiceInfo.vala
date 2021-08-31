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

public class FeedReader.ServiceInfo : Gtk.Overlay {
	private Gtk.Stack m_stack;
	private Gtk.Spinner m_spinner;
	private Gtk.Image m_logo;
	private Gtk.Label m_name;
	private Gtk.Label m_label;
	private Gtk.Label m_offline;
	private Gtk.Grid m_box;

	public ServiceInfo ()
	{
		// m_logo = new Gtk.Image ();
		m_logo = new Gtk.Image.from_file ("");
		m_label = new Gtk.Label ("") {
			halign = Gtk.Align.CENTER,
			margin_start = 10,
			margin_end = 10
		};
		m_label.set_ellipsize (Pango.EllipsizeMode.END);
		m_name = new Gtk.Label ("") {
			halign = Gtk.Align.CENTER,
			ellipsize = Pango.EllipsizeMode.END
		};
		m_name.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

		m_box = new Gtk.Grid () {
			orientation = Gtk.Orientation.VERTICAL,
			hexpand = true,
			halign = Gtk.Align.CENTER,
			valign = Gtk.Align.CENTER
		};
		m_box.add (m_logo);
		m_box.add (m_name);
		m_box.add (m_label);
		m_box.margin_top = 20;
		m_box.margin_bottom = 5;

		m_spinner = new Gtk.Spinner ();
		m_spinner.set_size_request (32,32);

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
		string? service_name = "";

		if (server == "https://feedbin.com/") {
			service_name = "Feedbin";
		} else if (server == "https://tt-rss.org/") {
			service_name = "Tiny Tiny RSS";
		} else if (server == "https://github.com/nextcloud/news") {
			service_name = "Nextcloud News";
		} else if (server == "http://www.inoreader.com/") {
			service_name = "InoReader";
		} else if (server == "https://freshrss.org/") {
			service_name = "freshRSS";
		} else if (server == "https://feedhq.org/") {
			service_name = "FeedHQ";
		} else if (server == "https://bazqux.com/") {
			service_name = "BazQux";
		} else if (server == "http://localhost/") {
			service_name = "Communique";
		}

		if (this.is_visible ()) {
			if (user_name == "none" || service_icon == "none") {
				m_spinner.start ();
				m_stack.set_visible_child_name ("spinner");
			}
			else {
				m_logo.set_from_icon_name (service_icon, Gtk.IconSize.BUTTON);
				// m_logo.get_style_context ().add_class ("fr-sidebar-symbolic");
				m_label.set_label (user_name);
				m_name.label = service_name;
				m_stack.set_visible_child_name ("info");
				if (server != "none")
				{
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
