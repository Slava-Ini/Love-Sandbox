-- Set relative path
package.path = "../lib/?.lua;" .. package.path

-- Bootstrap the compiler
local fennel = require("fennel")
table.insert(package.loaders, fennel.make_searcher({correlate=true}))

-- Require our Fennel source file
require("wrap")
