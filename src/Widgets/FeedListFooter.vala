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

public class FeedReader.FeedListFooter : Gtk.ActionBar {

	private Gtk.Box m_box;
	private Gtk.Stack m_addStack;
	private Gtk.Spinner m_addSpinner;
	private AddButton m_addButton;
	private RemoveButton m_removeButton;

	public FeedListFooter () {
		get_style_context  ().add_class (Gtk.STYLE_CLASS_FLAT);
		m_addButton = new AddButton ();
		m_removeButton = new RemoveButton ();
		m_addSpinner = new Gtk.Spinner ();
		// m_addSpinner.get_style_context ().add_class ("feedlist-spinner");
		m_addSpinner.margin = 4;
		m_addSpinner.start ();
		m_addStack = new Gtk.Stack ();
		m_addStack.add_named (m_addButton, "button");
		m_addStack.add_named (m_addSpinner, "spinner");
		m_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		m_box.pack_start (m_addStack);
		m_box.pack_start (m_removeButton);
		this.add (m_box);

		if (!FeedReaderBackend.get_default ().supportFeedManipulation ())
		{
			m_addButton.set_sensitive (false);
			m_removeButton.set_sensitive (false);
		}
	}

	public void setBusy ()
	{
		m_addStack.set_visible_child_name ("spinner");
		m_addStack.show_all ();
	}

	public void setReady ()
	{
		m_addStack.set_visible_child_name ("button");
		m_addSpinner.start ();
		m_addStack.show_all ();
	}

	public void setRemoveButtonSensitive (bool sensitive)
	{
		if (FeedReaderApp.get_default ().isOnline () && FeedReaderBackend.get_default ().supportFeedManipulation ())
		{
			m_removeButton.set_sensitive (sensitive);
		}
	}

	public void setSelectedRow (FeedListType type, string id)
	{
		m_removeButton.setSelectedRow (type, id);
	}

	public void setAddButtonSensitive (bool active)
	{
		if (FeedReaderBackend.get_default ().supportFeedManipulation ())
		{
			m_addButton.set_sensitive (active);
			m_removeButton.set_sensitive (active);
		}
	}

	public void showError (string errmsg)
	{
		var label = new Gtk.Label (errmsg);
		label.margin = 20;

		var pop = new Gtk.Popover (m_addStack);
		pop.add (label);
		pop.show_all ();
	}
}


public class FeedReader.AddButton : Gtk.MenuButton {
	public AddButton () {
		image = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
		get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
		always_show_image = true;
		label = _("Add RSS Feed...");
		popover = new AddPopover (this);
	}
}

public class FeedReader.RemoveButton : Gtk.MenuButton {
	private FeedListType m_type;
	private string m_id;

	public RemoveButton () {
		image = new Gtk.Image.from_icon_name ("list-remove-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
		clicked.connect (onClick);
		set_tooltip_text (_("Remove feed or category"));
	}

	public void onClick () {
		var pop = new RemovePopover (this, m_type, m_id);
		pop.show ();
	}

	public void setSelectedRow (FeedListType type, string id) {
		m_type = type;
		m_id = id;
	}
}
