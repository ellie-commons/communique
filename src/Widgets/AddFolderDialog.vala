/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2021 Your Name <singharajdeep97@gmail.com>
*/

public class FeedReader.AddFolderDialog : Hdy.Window {
    private Gtk.Entry name_entry;

    public AddFolderDialog () {
        Object (
            resizable: false,
            modal: true,
            transient_for: MainWindow.get_default (),
            type_hint: Gdk.WindowTypeHint.DIALOG,
            window_position: Gtk.WindowPosition.CENTER_ON_PARENT
        );
    }

    construct {
        var name_label = new Gtk.Label (_("Name:"));

        name_entry = new Gtk.Entry ();

        var entry_grid = new Gtk.Grid () {
            row_spacing = 6,
            column_spacing = 6
        };
        entry_grid.attach (name_label, 0, 0);
        entry_grid.attach (name_entry, 1, 0);

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        cancel_button.clicked.connect (() => {
            destroy ();
        });

        var add_folder_button = new Gtk.Button.with_label (_("Add Folder")) {
            can_default = true
        };
        add_folder_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        add_folder_button.clicked.connect (() => {
            add_folder ();
        });

        var action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            margin_top = 12,
            spacing = 6,
            valign = Gtk.Align.END,
            vexpand = true
        };
        action_area.add (cancel_button);
        action_area.add (add_folder_button);

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

    private void add_folder () {
        string name = name_entry.text;

        if (name == "") {
            name_entry.grab_focus ();
            return;
        }

        Logger.debug ("add_folder");

        FeedReaderBackend.get_default ().addCategory (name, "", true);

        this.destroy ();

        FeedReaderBackend.get_default ().startSync (false);

        // set_busy ();
    }
}
