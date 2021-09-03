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

public class FeedReader.ResetPage : Gtk.Dialog {
	private Gtk.Button reset_button;

	private bool m_reset;

	public signal void reset ();
	public signal void cancel ();

	public ResetPage () {
		get_style_context ().add_class ("csd");

		transient_for = MainWindow.get_default ();

		var headerbar = new Gtk.HeaderBar () {
			has_subtitle = false
		};
		headerbar.get_style_context ().add_class ("default-decoration");
		headerbar.show ();

		set_titlebar (headerbar);
	}

	construct {
		m_reset = false;

		deletable = false;
		skip_taskbar_hint = true;
		window_position = Gtk.WindowPosition.CENTER_ON_PARENT;

		var image = new Gtk.Image.from_icon_name ("dialog-warning", Gtk.IconSize.DIALOG);

		var badge = new Gtk.Image () {
    		gicon = new ThemedIcon ("avatar-default"),
    		pixel_size = 24,
    		halign = Gtk.Align.END,
    		valign = Gtk.Align.END
		};

		var overlay = new Gtk.Overlay () {
			valign = Gtk.Align.START
		};
		overlay.add (image);
		overlay.add_overlay (badge);

		var primary_label = new Gtk.Label (_("Are you sure you want to change your account?"));
	    primary_label.get_style_context ().add_class (Granite.STYLE_CLASS_PRIMARY_LABEL);
        primary_label.selectable = true;
        primary_label.max_width_chars = 50;
        primary_label.wrap = true;
        primary_label.xalign = 0;

		var secondary_label = new Gtk.Label (_("This will delete all local data."));
		secondary_label.use_markup = true;
		secondary_label.selectable = true;
		secondary_label.max_width_chars = 50;
		secondary_label.wrap = true;
		secondary_label.xalign = 0;

		// reset_button = new Gtk.Button.with_label (_("Change Account"));
		// reset_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

		var message_grid = new Gtk.Grid ();
        message_grid.column_spacing = 12;
		message_grid.row_spacing = 6;
		message_grid.margin_start = message_grid.margin_end = 12;
		message_grid.attach (overlay, 0, 0, 1, 2);
		message_grid.attach (primary_label, 1, 0, 1, 1);
		message_grid.attach (secondary_label, 1, 1, 1, 1);
		message_grid.show_all ();

		get_content_area ().add (message_grid);
		add_button ("Cancel", Gtk.ResponseType.CANCEL);
		// add_button (reset_button, Gtk.ResponseType.ACCEPT);
		var reset_button = add_button (_("Change Account"), Gtk.ResponseType.ACCEPT);
		reset_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

		response.connect ((response_id) => {
			if (response_id == Gtk.ResponseType.ACCEPT) {
				resetAllData ();
				close ();
			} else if (response_id == Gtk.ResponseType.CANCEL) {
				abortReset ();
				close ();
			}
		});
	}

	private void resetAllData () {
		if (Settings.state ().get_boolean ("currently-updating")) {
			m_reset = true;
			// m_newAccountButton.remove(m_deleteLabel);
			// m_newAccountButton.add(m_waitingBox);
			// m_waitingBox.show_all();
			// m_spinner.start();
			// m_newAccountButton.set_sensitive(false);
			FeedReaderBackend.get_default ().cancelSync ();

			while (Settings.state ().get_boolean("currently-updating")) {
				Gtk.main_iteration ();
			}

			if (!m_reset) {
				return;
			}
		}

		// set "currently-updating" ourself to prevent the backend to start sync
		Settings.state ().set_boolean ("currently-updating", true);

		// clear all data from UI
		ColumnView.get_default ().clear();

		Settings.general ().reset ("plugin");
		Utils.resetSettings (Settings.state ());
		FeedReaderBackend.get_default ().resetDB ();
		FeedReaderBackend.get_default ().resetAccount ();

		Utils.remove_directory (GLib.Environment.get_user_data_dir () + "/communique/data/images/");

		Settings.state ().set_boolean ("currently-updating", false);
		FeedReaderBackend.get_default ().login ("none");

		// Load all available plugins, to present them on the login page
		FeedServer.get_default ().LoadAllPlugins ();

		reset ();
	}

	private void abortReset () {
		m_reset = false;
		// m_newAccountButton.remove (m_waitingBox);
		// m_newAccountButton.add (m_deleteLabel);
		// m_deleteLabel.show_all ();
		// m_newAccountButton.set_sensitive (true);
		cancel ();
	}
}
