# Versioning

The version tag is stored as a visible `CreateText` element in `example.client.luau`, using the `tag` icon and `MAJOR.MINOR.PATCH` text.

For every push to `main`, increment the patch component by one before committing. For example, `0.0.3` becomes `0.0.4`, then `0.0.5` on the next push. Keep the visible version element synchronized with the commit that is pushed.
