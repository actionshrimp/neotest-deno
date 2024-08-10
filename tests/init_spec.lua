local async = require("nio").tests
local neotest_deno = require("neotest-deno")

describe("DenoNeotestAdapter.init", function()
	async.it("has the correct name", function()
		assert.equals(neotest_deno.name, "neotest-deno")
	end)
end)

describe("DenoNeotestAdapter.is_test_file", function()
	local nix_src_dir = "/home/user/deno/app"
	local win_src_dir = "C:\\Users\\user\\Documents\\deno\\app"

	local valid_exts = { "js", "ts", "tsx", "mts", "mjs", "jsx", "cjs", "cts" }

	describe("Validates unix-style paths", function()
		async.it("recognizes files named test.<ext>", function()
			for _, ext in pairs(valid_exts) do
				local fn = nix_src_dir .. "/test." .. ext
				assert.True(neotest_deno.is_test_file(fn))
			end
		end)

		async.it("recognizes files named *.test.<ext>", function()
			for _, ext in pairs(valid_exts) do
				local fn = nix_src_dir .. "/app.test." .. ext
				assert.True(neotest_deno.is_test_file(fn))
			end
		end)

		async.it("recognizes files named *_test.<ext>", function()
			for _, ext in pairs(valid_exts) do
				local fn = nix_src_dir .. "/app_test." .. ext
				assert.True(neotest_deno.is_test_file(fn))
			end
		end)

		async.it("rejects files with invalid names", function()
			assert.False(neotest_deno.is_test_file(nix_src_dir .. "/apptest.ts"))
			assert.False(neotest_deno.is_test_file(nix_src_dir .. "/Test.js"))
			assert.False(neotest_deno.is_test_file(nix_src_dir .. "/app.test.unit.tsx"))
			assert.False(neotest_deno.is_test_file(nix_src_dir .. "/main.jsx"))
			assert.False(neotest_deno.is_test_file(nix_src_dir .. "/app_Test.mts"))
		end)

		async.it("rejects files with invalid extensions", function()
			assert.False(neotest_deno.is_test_file(nix_src_dir .. "/test.json"))
			assert.False(neotest_deno.is_test_file(nix_src_dir .. "/app.test.rs"))
			assert.False(neotest_deno.is_test_file(nix_src_dir .. "/app_test.md"))
		end)
	end)

	describe("Validates Windows-style paths", function()
		async.it("recognizes files named test.<ext>", function()
			for _, ext in pairs(valid_exts) do
				local fn = win_src_dir .. "\\test." .. ext
				assert.True(neotest_deno.is_test_file(fn))
			end
		end)

		async.it("recognizes files named *.test.<ext>", function()
			for _, ext in pairs(valid_exts) do
				local fn = win_src_dir .. "\\app.test." .. ext
				assert.True(neotest_deno.is_test_file(fn))
			end
		end)

		async.it("recognizes files named *_test.<ext>", function()
			for _, ext in pairs(valid_exts) do
				local fn = win_src_dir .. "\\app_test." .. ext
				assert.True(neotest_deno.is_test_file(fn))
			end
		end)

		async.it("rejects files with invalid names", function()
			assert.False(neotest_deno.is_test_file(win_src_dir .. "\\apptest.ts"))
			assert.False(neotest_deno.is_test_file(win_src_dir .. "\\Test.js"))
			assert.False(neotest_deno.is_test_file(win_src_dir .. "\\app.test.unit.tsx"))
			assert.False(neotest_deno.is_test_file(win_src_dir .. "\\main.jsx"))
			assert.False(neotest_deno.is_test_file(win_src_dir .. "\\app_Test.mts"))
		end)

		async.it("rejects files with invalid extensions", function()
			assert.False(neotest_deno.is_test_file(win_src_dir .. "\\test.json"))
			assert.False(neotest_deno.is_test_file(win_src_dir .. "\\app.test.rs"))
			assert.False(neotest_deno.is_test_file(win_src_dir .. "\\app_test.md"))
		end)
	end)
end)

-- TODO: More tests!

--describe("DenoNeotestAdapter.root", function()
--end)
--
--describe("DenoNeotestAdapter.filter_dir", function()
--end)

describe("DenoNeotestAdapter.discover_positions", function()
	async.it("provides meaningful names from a basic flat DenoTest", function()
		local positions = neotest_deno.discover_positions("./samples/1.tests.test.ts"):to_list()

		local expected_output = {
			{ name = "1.tests.test.ts", type = "file" },
			{
				{ name = "hello world #1", type = "test" },
				{ name = "hello world #1.5", type = "test" },
				{ name = "helloWorld3", type = "test" },
				{ name = "hello world #2", type = "test" },
				{ name = "hello world #2.5", type = "test" },
				{ name = "hello world #4", type = "test" },
				{ name = "hello world #5", type = "test" },
				{ name = "helloWorld6", type = "test" },
				{ name = "hello world #7", type = "test" },
			},
		}

		assert.equals(expected_output[1].name, positions[1].name)
		assert.equals(expected_output[1].type, positions[1].type)

		for i, expected in ipairs(expected_output[2]) do
			assert.is.truthy(expected)
			---@type neotest.Position
			local position = positions[i + 1][1]
			assert.is.truthy(position)
			assert.equals(expected.name, position.name)
			assert.equals(expected.type, position.type)
		end
	end)

	async.it("provides meaningful names from a basic async flat DenoTest", function()
		local positions = neotest_deno.discover_positions("./samples/2.async_tests.test.ts"):to_list()

		local expected_output = {
			{ name = "2.async_tests.test.ts", type = "file" },
			{ name = "async hello world", type = "test" },
		}

		assert.equals(expected_output[1].name, positions[1].name)
		assert.equals(expected_output[1].type, positions[1].type)
		assert.equals(expected_output[2].name, positions[2][1].name)
		assert.equals(expected_output[2].type, positions[2][1].type)
	end)

	async.it("provides meaningful names from a basic nested DenoTest", function()
		local positions = neotest_deno.discover_positions("./samples/3.test_steps.test.ts"):to_list()

		local expected_output = {
			{ name = "3.test_steps.test.ts", type = "file" },
			{
				{ name = "database", type = "test" },
				{ { name = "insert user", type = "test" } },
				{ { name = "insert book", type = "test" } },
				{
					{ name = "update and delete", type = "test" },
					{ { name = "update", type = "test" } },
					{ { name = "delete", type = "test" } },
				},
				{
					{ name = "copy books", type = "test" },
					{ { name = "1", type = "test" } },
					{ { name = "2", type = "test" } },
				},
			},
		}

		assert.equals(expected_output[1].name, positions[1].name)
		assert.equals(expected_output[1].type, positions[1].type)
		assert.equals(expected_output[2][1].name, positions[2][1].name)
		assert.equals(expected_output[2][1].type, positions[2][1].type)
		assert.equals(expected_output[2][2][1].name, positions[2][2][1].name)
		assert.equals(expected_output[2][2][1].type, positions[2][2][1].type)
		assert.equals(expected_output[2][3][1].name, positions[2][3][1].name)
		assert.equals(expected_output[2][3][1].type, positions[2][3][1].type)
		assert.equals(expected_output[2][4][1].name, positions[2][4][1].name)
		assert.equals(expected_output[2][4][1].type, positions[2][4][1].type)
		assert.equals(expected_output[2][4][2][1].name, positions[2][4][2][1].name)
		assert.equals(expected_output[2][4][2][1].type, positions[2][4][2][1].type)
		assert.equals(expected_output[2][4][3][1].name, positions[2][4][3][1].name)
		assert.equals(expected_output[2][4][3][1].type, positions[2][4][3][1].type)
		assert.equals(expected_output[2][5][1].name, positions[2][5][1].name)
		assert.equals(expected_output[2][5][1].type, positions[2][5][1].type)
		assert.equals(expected_output[2][5][2][1].name, positions[2][5][2][1].name)
		assert.equals(expected_output[2][5][2][1].type, positions[2][5][2][1].type)
		assert.equals(expected_output[2][5][3][1].name, positions[2][5][3][1].name)
		assert.equals(expected_output[2][5][3][1].type, positions[2][5][3][1].type)
	end)

	async.it("provides meaningful names from a basic flat bdd", function()
		local positions = neotest_deno.discover_positions("./samples/5.bdd_flat.test.ts"):to_list()

		local expected_output = {
			{ name = "5.bdd_flat.test.ts", type = "file" },
			{
				{ name = "users initially empty", type = "test" },
				{ name = "constructor", type = "test" },
				{ name = "getAge", type = "test" },
				{ name = "setAge", type = "test" },
			},
		}

		assert.equals(expected_output[1].name, positions[1].name)
		assert.equals(expected_output[1].type, positions[1].type)

		for i, expected in ipairs(expected_output[2]) do
			assert.is.truthy(expected)
			local position = positions[i + 1][1]
			assert.is.truthy(position)
			assert.equals(expected.name, position.name)
			assert.equals(expected.type, position.type)
		end
	end)

	async.it("provides meaningful names from a basic nested bdd", function()
		local positions = neotest_deno.discover_positions("./samples/4.bdd_nested.test.ts"):to_list()

		local expected_output = {
			{ name = "4.bdd_nested.test.ts", type = "file" },
			{
				{ name = "User", type = "namespace" },
				{ { name = "users initially empty", type = "test" } },
				{ { name = "constructor", type = "test" } },
				{
					{ name = "age", type = "namespace" },
					{ { name = "getAge", type = "test" } },
					{ { name = "setAge", type = "test" } },
				},
			},
		}

		assert.equals(expected_output[1].name, positions[1].name)
		assert.equals(expected_output[1].type, positions[1].type)
		assert.equals(expected_output[2][1].name, positions[2][1].name)
		assert.equals(expected_output[2][1].type, positions[2][1].type)
		assert.equals(expected_output[2][2][1].name, positions[2][2][1].name)
		assert.equals(expected_output[2][2][1].type, positions[2][2][1].type)
		assert.equals(expected_output[2][3][1].name, positions[2][3][1].name)
		assert.equals(expected_output[2][3][1].type, positions[2][3][1].type)
		assert.equals(expected_output[2][4][1].name, positions[2][4][1].name)
		assert.equals(expected_output[2][4][1].type, positions[2][4][1].type)
		assert.equals(expected_output[2][4][2][1].name, positions[2][4][2][1].name)
		assert.equals(expected_output[2][4][2][1].type, positions[2][4][2][1].type)
		assert.equals(expected_output[2][4][3][1].name, positions[2][4][3][1].name)
		assert.equals(expected_output[2][4][3][1].type, positions[2][4][3][1].type)
	end)
end)

--describe("DenoNeotestAdapter.build_spec", function()
--end)
--
--describe("DenoNeotestAdapter.results", function()
--end)
