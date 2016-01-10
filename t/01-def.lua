local Registry = require 'registry'
describe("def object", function ()
	describe("Attrs", function ()
		it("specifies simple properties", function ()
			local r = Registry:new()
			r:register('Simple Def'):Attrs{
				foo = 'bar',
				blorg = 'pow'
			}
			local TestDef = r:get('Simple Def')
			assert.are.same(TestDef:Render(), {
				foo = 'bar',
				blorg = 'pow'
			})
		end)

		it("specifies nested tables", function ()
			local r = Registry:new()

			r:register('Nested Def'):Attrs{
				foo = {
					bar = {
						baz = "woop"
					}
				}
			}
			local TestDef = r:get('Nested Def')
			assert.are.same(TestDef:Render(), {
				foo = {
					bar = {
						baz = "woop"
					}
				}
			})
		end)

		it("results in 'self' as the source for the key", function ()
			local r = Registry:new()
			r:register('Self Def'):Attrs{ foo = "bar" }

			local testDef = r:get('Self Def')
			local fooSource = testDef:getKeySource('foo')
			assert.are.same(testDef, fooSource)
		end)
	end)
	describe('asdfsd', function ()

	end)
end)
