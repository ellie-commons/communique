/**
 * libdecsync.vapi
 *
 * Copyright (C) 2019 Aldo Gunsing
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, see <http://www.gnu.org/licenses/>.
 */

[CCode (cheader_filename = "libdecsync.h")]
namespace Decsync {
	[Compact]
	[CCode (cname = "DecsyncEntryWithPath", cprefix = "decsync_entry_with_path_", free_function = "decsync_entry_with_path_free")]
	public class EntryWithPath {
		public EntryWithPath(string[] path, string key, string value);
	}

	[Compact]
	[CCode (cname = "DecsyncEntry", cprefix = "decsync_entry_", free_function = "decsync_entry_free")]
	public class Entry {
		public Entry(string key, string value);
	}

	[Compact]
	[CCode (cname = "DecsyncStoredEntry", cprefix = "decsync_stored_entry_", free_function = "decsync_stored_entry_free")]
	public class StoredEntry {
		public StoredEntry(string[] path, string key);
	}

	[Compact]
	[CCode (cname = "Decsync", cprefix = "decsync_", free_function = "decsync_free")]
	public class Decsync<T> {
		[CCode (has_typedef = false, has_target = false)]
		public delegate void Listener<T>(string[] path, string datetime, string key, string value, T extra);

		public static int new(out Decsync<T> decsync, string? decsync_dir, string sync_type, string? collection, string own_app_id);
		public void init_done();

		public void add_listener(string[] path, Listener<T> listener);
		public void set_entry(string[] path, string key, string value);
		public void set_entries(EntryWithPath[] entries_with_path);
		public void set_entries_for_path(string[] path, Entry[] entries);
		public void execute_all_new_entries(T extra);
		public void execute_stored_entry(string[] path, string key, T extra);
		public void execute_stored_entries(StoredEntry[] stored_entries, T extra);
		public void execute_stored_entries_for_path_exact(string[] path, T extra, string[] keys);
		public void execute_all_stored_entries_for_path_exact(string[] path, T extra);
		public void execute_stored_entries_for_path_prefix(string[] path, T extra, string[] keys);
		public void execute_all_stored_entries_for_path_prefix(string[] path, T extra);
		[Version (deprecated = true)]
		public void execute_stored_entries_for_path(string[] path, T extra, string[] keys);
		[Version (deprecated = true)]
		public void execute_all_stored_entries_for_path(string[] path, T extra);
		public void init_stored_entries();
		public void latest_app_id(char[] app_id);
	}

	[CCode (cname = "decsync_get_static_info")]
	public void get_static_info(string? decsync_dir, string sync_type, string? collection, string key, char[] value);

	[CCode (cname = "decsync_check_decsync_info")]
	public int check_decsync_info(string? decsync_dir);

	[CCode (cname = "decsync_list_collections")]
	private int _list_collections(string? decsync_dir, string sync_type, [CCode (array_length = false)] char[] collections, int max_len);

	[CCode (cname = "decsync_list_collections_vala")]
	public string[] list_collections(string? decsync_dir, string sync_type, int max_len = 256) {
		string[] result = {};
		var collections = new char[max_len*256];
		var len = _list_collections(decsync_dir, sync_type, collections, max_len);
		for (int i = 0; i < len; i++) {
			result += (string)collections[i*256:(i+1)*256];
		}
		return result;
	}

	[CCode (cname = "decsync_get_app_id")]
	public void get_app_id(string app_name, char[] app_id);

	[CCode (cname = "decsync_get_app_id_with_id")]
	public void get_app_id_with_id(string app_name, int id, char[] app_id);

	[CCode (cname = "decsync_get_default_dir")]
	public void get_default_dir(char[] decsync_dir);
}
