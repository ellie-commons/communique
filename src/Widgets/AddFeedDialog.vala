/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2021 Your Name <singharajdeep97@gmail.com>
*/

public class FeedReader.AddFeedDialog : Hdy.Window {
    private Gtk.Entry url_entry;
    private Gtk.Entry folder_entry;

    public AddFeedDialog () {
        Object (
            resizable: false,
            modal: true,
            transient_for: MainWindow.get_default (),
            type_hint: Gdk.WindowTypeHint.DIALOG,
            window_position: Gtk.WindowPosition.CENTER_ON_PARENT
        );
    }

    construct {
        var url_label = new Gtk.Label (_("URL:"));

        url_entry = new Gtk.Entry ();

        var folder_label = new Gtk.Label (_("Folder:"));

        folder_entry = new Gtk.Entry () {
            placeholder_text = _("No Folder")
        };
        folder_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");

        var entry_grid = new Gtk.Grid () {
            row_spacing = 6,
            column_spacing = 6
        };
        entry_grid.attach (url_label, 0, 0);
        entry_grid.attach (url_entry, 1, 0);
        entry_grid.attach (folder_label, 0, 1);
        entry_grid.attach (folder_entry, 1, 1);

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        cancel_button.clicked.connect (() => {
            destroy ();
        });

        var add_feed_button = new Gtk.Button.with_label (_("Add Feed")) {
            can_default = true
        };
        add_feed_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        add_feed_button.clicked.connect (() => {
            add_feed ();
        });

        var action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            margin_top = 12,
            spacing = 6,
            valign = Gtk.Align.END,
            vexpand = true
        };
        action_area.add (cancel_button);
        action_area.add (add_feed_button);

        var main_grid = new Gtk.Grid () {
            margin = 12,
            orientation = Gtk.Orientation.VERTICAL
        };
        main_grid.add (entry_grid);
        main_grid.add (action_area);

        var window_handle = new Hdy.WindowHandle ();
        window_handle.add (main_grid);

        add (window_handle);

        show_all ();
    }

    private void add_feed () {
        string url = url_entry.text;
        
        // if (url == "") {
        //     url_entry.grab_focus ();
        //     return;
        // }

        string? folder_id = DataBase.readOnly ().getCategoryID (folder_entry.text);
        bool is_id = true;

        if (folder_id == null) {
	        folder_id = folder_entry.text;
	        is_id = false;
	    }

	    if (GLib.Uri.parse_scheme (url) == null) {
	        url = "http://" + url;
	    }

	    Logger.debug ("add_feed: %s, %s".printf (url, (folder_id == "") ? "null" : folder_id));
	    
	    FeedReaderBackend.get_default ().addFeed (url, folder_id, is_id);

	    set_busy ();
    }

    private void set_busy () {
        ColumnView.get_default ().footerSetBusy ();
        this.destroy ();
    }
}
