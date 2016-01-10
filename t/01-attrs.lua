local Registry = require 'registry'
describe("simple instantiation", function ()

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
end)
