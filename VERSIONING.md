# Versioning

The version tag is stored as a visible `Window:CreateTag` element beside the window title in `example.client.luau`, using the `tag` icon and `MAJOR.MINOR.PATCH` text.

For every push to `main`, increment the patch component by one before committing. For example, `0.0.4` becomes `0.0.5`, then `0.0.6` on the next push. Keep the visible title-side tag synchronized with the commit that is pushed.
