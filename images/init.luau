-- Image service entrypoint (images/init.luau).
--
-- Image loading and lookup live in images/image.luau (moved from
-- utilities/image.luau unchanged in behavior); the on-disk/remote cache lives
-- in cache/imageCache.luau; built-in window icon ids/roles live in
-- images/windowIcons.luau. Constants for image-related z-order etc. remain in
-- utilities/constants.luau.

-- This file IS the `images` ModuleScript (init.luau semantics).
local image = require(script.image)

local images = {
    -- loading / assignment / resolve
    resolve = image.resolve,
    assign = image.assign,
    preload = image.preload,
    avatar = image.avatar,
    rewrites = image.rewrites,
}

return images
