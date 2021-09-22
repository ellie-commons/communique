/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2021 Your Name <singharajdeep97@gmail.com>
*/

public class FeedReader.Shortcuts : Hdy.Window {
    public Shortcuts () {
        Object (
            resizable: false,
            modal: true,
            transient_for: MainWindow.get_default (),
            type_hint: Gdk.WindowTypeHint.DIALOG,
            window_position: Gtk.WindowPosition.CENTER_ON_PARENT
        );
    }
    construct {
        var column_start = new Gtk.Grid () {
            column_spacing = 6,
            hexpand = true,
            row_spacing = 12
        };

        column_start.attach (new Granite.HeaderLabel (_("Articles")), 0, 0, 2);
        column_start.attach (new NameLabel (_("Move to previous article:")), 0, 1);
        column_start.attach (new ShortcutLabel (_("J")), 1, 1);
        column_start.attach (new NameLabel (_("Move to next article:")), 0, 2);
        column_start.attach (new ShortcutLabel (_("K")), 1, 2);
        column_start.attach (new NameLabel (_("Scroll article up:")), 0, 3);
        column_start.attach (new ShortcutLabel (_("I")), 1, 3);
        column_start.attach (new NameLabel (_("Scroll article down:")), 0, 4);
        column_start.attach (new ShortcutLabel (_("U")), 1, 4);
        column_start.attach (new NameLabel (_("Toggle article read:")), 0, 5);
        column_start.attach (new ShortcutLabel (_("R")), 1, 5);
        column_start.attach (new NameLabel (_("Open article in browser:")), 0, 6);
        column_start.attach (new ShortcutLabel (_("O")), 1, 6);
        column_start.attach (new NameLabel (_("Center selected article:")), 0, 7);
        column_start.attach (new ShortcutLabel (_("S")), 1, 7);

        var column_end = new Gtk.Grid () {
            column_spacing = 6,
            hexpand = true,
            row_spacing = 12
        };

        column_end.attach (new Granite.HeaderLabel (_("Feeds")), 0, 8, 2);
        column_end.attach (new NameLabel (_("Move to previous feed:")), 0, 9);
        column_end.attach (new ShortcutLabel (_("Ctrl")), 1, 9);
        column_end.attach (new ShortcutLabel (_("J")), 2, 9);
        column_end.attach (new NameLabel (_("Move to next article:")), 0, 10);
        column_end.attach (new ShortcutLabel (_("Ctrl")), 1, 10);
        column_end.attach (new ShortcutLabel (_("K")), 2, 10);
        column_end.attach (new NameLabel (_("Toggle feed read:")), 0, 11);
        column_end.attach (new ShortcutLabel (_("Shift")), 1, 11);
        column_end.attach (new ShortcutLabel (_("A")), 2, 11);

        column_end.attach (new Granite.HeaderLabel (_("Global")), 0, 12, 2);
        column_end.attach (new NameLabel (_("Global sync:")), 0, 13);
        column_end.attach (new ShortcutLabel (_("Ctrl")), 1, 13);
        column_end.attach (new ShortcutLabel (_("R")), 2, 13);
        column_end.attach (new NameLabel (_("Search.. :")), 0, 14);
        column_end.attach (new ShortcutLabel (_("Ctrl")), 1, 14);
        column_end.attach (new ShortcutLabel (_("F")), 2, 14);

        var column_grid = new Gtk.Grid () {
            column_spacing = 48,
            margin = 36,
            margin_top = 12
        };
        column_grid.add (column_start);
        column_grid.add (new Gtk.Separator (Gtk.Orientation.VERTICAL));
        column_grid.add (column_end);

        var headerbar = new Gtk.HeaderBar () {
            decoration_layout = "close:",
            show_close_button = true,
            title = _("Shortcuts")
        };
        headerbar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        headerbar.get_style_context ().add_class (Gtk.STYLE_CLASS_TITLEBAR);
        headerbar.get_style_context ().add_class ("default-decoration");

        var main_grid = new Gtk.Grid ();

        main_grid.attach (headerbar, 0, 1);
        main_grid.attach (column_grid, 0, 2);

        add (main_grid);

        show_all ();
    }

    private class NameLabel : Gtk.Label {
        public NameLabel (string label) {
            Object (
                label: label
            );
        }

        construct {
            halign = Gtk.Align.END;
            xalign = 1;
        }
    }

    private class ShortcutLabel : Gtk.Label {
        public ShortcutLabel (string label) {
            Object (
                label: label
            );
        }

        construct {
            get_style_context ().add_class ("keycap");
        }
    }
}
