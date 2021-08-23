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

public class FeedReader.ShareRow : Gtk.ListBoxRow {

	private string m_id;
	private string m_type;

	public ShareRow(string type, string id, string username, string iconName) {
		get_style_context ().add_class (Gtk.STYLE_CLASS_MENUITEM);

		m_id = id;
		m_type = type;
		var icon = new Gtk.Image.from_icon_name(iconName, Gtk.IconSize.DND) {
			tooltip_text = _(type),
			margin_start = 6
		};

		string service_name = "";

		if (type == "instapaper") {
			service_name = "Instapaper";
			var service_label = new Gtk.Label (service_name) {
				halign = Gtk.Align.START,
				margin_top = 6
			};
			service_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

			var username_label = new Gtk.Label (username) {
				halign = Gtk.Align.START,
				margin_bottom = 6,
				margin_end = 6
			};
			username_label.get_style_context ().add_class (Granite.STYLE_CLASS_SMALL_LABEL);

			var grid = new Gtk.Grid () {
				column_spacing = 6
			};
			grid.attach (icon, 0, 0, 1, 2);
			grid.attach (service_label, 1, 0);
			grid.attach (username_label, 1, 1);

			add (grid);
		} else if (type == "pocket") {
			service_name = "Pocket";
			var service_label = new Gtk.Label (service_name) {
				halign = Gtk.Align.START,
				margin_top = 6
			};
			service_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

			var username_label = new Gtk.Label (username) {
				halign = Gtk.Align.START,
				margin_bottom = 6,
				margin_end = 6
			};
			username_label.get_style_context ().add_class (Granite.STYLE_CLASS_SMALL_LABEL);

			var grid = new Gtk.Grid () {
				column_spacing = 6
			};
			grid.attach (icon, 0, 0, 1, 2);
			grid.attach (service_label, 1, 0);
			grid.attach (username_label, 1, 1);

			add (grid);
		} else if (type == "mail") {
			service_name = "Send via email";
			var service_label = new Gtk.Label (service_name) {
				halign = Gtk.Align.START,
				margin_top = 6
			};
			service_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

			var grid = new Gtk.Grid () {
				column_spacing = 6,
				margin_top = 3,
				margin_bottom = 3
			};
			grid.attach (icon, 0, 0, 1, 2);
			grid.attach (service_label, 1, 0);

			add (grid);
		} else if (type == "browser") {
			service_name = "Open in Browser";
			var service_label = new Gtk.Label (service_name) {
				halign = Gtk.Align.START,
				margin_top = 6
			};
			service_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

			var grid = new Gtk.Grid () {
				column_spacing = 6,
				margin_top = 3,
				margin_bottom = 3
			};
			grid.attach (icon, 0, 0, 1, 2);
			grid.attach (service_label, 1, 0);

			add (grid);
		}
	}

	public string getID () {
		return m_id;
	}

	public string getType() {
		return m_type;
	}
}
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

// public class FeedReader.ShareRow : Gtk.Button {

// 	private string m_id;
// 	private string m_type;

// 	public ShareRow(string type, string id, string username, string iconName) {
// 		get_style_context ().add_class (Gtk.STYLE_CLASS_MENUITEM);
// 		get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

// 		m_id = id;
// 		m_type = type;
// 		var icon = new Gtk.Image.from_icon_name(iconName, Gtk.IconSize.DND);

		// string service_name = "";

		// if (type == "instapaper") {
		// 	service_name = "Instapaper";
		// }

		// var service_label = new Gtk.Label (service_name) {
		// 	halign = Gtk.Align.START
		// };
		// service_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

		// var username_label = new Gtk.Label (username) {
		// 	halign = Gtk.Align.START
		// };
		// username_label.get_style_context ().add_class (Granite.STYLE_CLASS_SMALL_LABEL);

		// var grid = new Gtk.Grid () {
		// 	column_spacing = 6
		// };
		// grid.attach (icon, 0, 0, 1, 2);
		// grid.attach (service_label, 1, 0);
		// grid.attach (username_label, 1, 1);

// 		add (grid);
// 	}

// 	public string getID () {
// 		return m_id;
// 	}

// 	public string getType() {
// 		return m_type;
// 	}
// }
