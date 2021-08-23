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

public class FeedReader.ArticleViewUrlOverlay : Gtk.Revealer {

	private Gtk.Label m_label;

	public ArticleViewUrlOverlay ()
	{
		m_label = new Gtk.Label (null) {
			margin_start = 6,
			margin_end = 6
		};
		m_label.height_request = 25;

		var grid = new Gtk.Grid ();
		grid.get_style_context ().add_class (Granite.STYLE_CLASS_OVERLAY_BAR);
		grid.add (m_label);

		this.valign = Gtk.Align.END;
		this.halign = Gtk.Align.START;
		this.set_transition_type (Gtk.RevealerTransitionType.CROSSFADE);
		this.set_transition_duration (300);
		this.add (grid);
	}

	public void setURL (string uri, Gtk.Align align)
	{
		int length = 45;
		string url = uri;
		if (url.length >= length)
		{
			url = url.substring (0, length-3) + "...";
		}
		m_label.label = url;
		this.halign = align;
	}

	public void reveal (bool show)
	{
		if (show)
		{
			this.visible = true;
			m_label.show ();
		}

		this.set_reveal_child (show);
	}
}
