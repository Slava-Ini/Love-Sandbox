-- Bootstrap the compiler
local fennel = require("lib.fennel")
table.insert(package.loaders, fennel.make_searcher({correlate=true}))

-- Require our Fennel source file
require("wrap")
