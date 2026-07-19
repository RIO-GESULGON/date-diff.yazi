--- @since 25.5.28
-- DateDiff: Show the modification-time difference between two selected files.

local get_selected_urls = ya.sync(function(_)
	local urls = {}
	for _, url in pairs(cx.active.selected) do
		urls[#urls + 1] = url
	end
	return urls
end)

local function pluralize(value, unit)
	return string.format("%d %s%s", value, unit, value == 1 and "" or "s")
end

local function format_duration(seconds)
	seconds = math.floor(math.abs(seconds))
	if seconds == 0 then
		return "0 seconds"
	end

	local years = math.floor(seconds / 31536000)
	seconds = seconds % 31536000
	local months = math.floor(seconds / 2592000)
	seconds = seconds % 2592000
	local days = math.floor(seconds / 86400)
	seconds = seconds % 86400
	local hours = math.floor(seconds / 3600)
	seconds = seconds % 3600
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60

	local parts = {}
	if years > 0 then table.insert(parts, pluralize(years, "year")) end
	if months > 0 then table.insert(parts, pluralize(months, "month")) end
	if days > 0 then table.insert(parts, pluralize(days, "day")) end
	if hours > 0 then table.insert(parts, pluralize(hours, "hour")) end
	if minutes > 0 then table.insert(parts, pluralize(minutes, "minute")) end
	if secs > 0 then table.insert(parts, pluralize(secs, "second")) end

	return table.concat(parts, ", ")
end

local function format_datetime(timestamp)
	return os.date("%Y-%m-%d %H:%M:%S", math.floor(timestamp))
end

local function notify(title, content, level, timeout)
	return ya.notify({
		title = title,
		content = content,
		timeout = timeout or 5,
		level = level or "info",
	})
end

return {
	entry = function()
		ya.err("[date-diff2] entry start")
		local urls = get_selected_urls()
		ya.err("[date-diff2] got " .. tostring(#urls) .. " urls")

		if #urls ~= 2 then
			notify("DateDiff", "Please select exactly 2 files.", "warn", 3)
			return
		end

		local items = {}
		for _, url in ipairs(urls) do
			local cha, err = fs.cha(url)
			if not cha then
				notify("DateDiff", string.format("Failed to read metadata for %s: %s", tostring(url), err or "unknown error"), "error", 5)
				return
			end

			local mtime = cha.mtime
			if not mtime or mtime == 0 then
				notify("DateDiff", string.format("No modification time available for %s", tostring(url)), "warn", 4)
				return
			end

			table.insert(items, {
				name = tostring(url.name or url),
				mtime = math.floor(mtime),
			})
		end

		if items[1].mtime > items[2].mtime then
			items[1], items[2] = items[2], items[1]
		end

		local diff_seconds = items[2].mtime - items[1].mtime
		local message = string.format(
			"%s  —  %s\n%s  —  %s\n\nDifference: %s",
			format_datetime(items[1].mtime), items[1].name,
			format_datetime(items[2].mtime), items[2].name,
			format_duration(diff_seconds)
		)

		notify("DateDiff", message, "info", 6)
		ya.err("[date-diff2] entry end")
	end,
}
