local Registry = require 'registry'
describe("def object", function ()
	describe("Render", function ()
		it("renders an empty table for an empty def", function ()
			local r = Registry:new()
			r:register('Simple Def')
			local TestDef = r:get('Simple Def')
			assert.are.same(TestDef:Render(), {})
		end)
	end)

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

	describe('Extends', function ()
		it("inherits simple properties", function ()
			local r = Registry:new()
			r:register('Base Def'):Attrs{
				foo = 'bar',
				blorg = 'pow'
			}
			r:register('Child Def'):Extends('Base Def')
			local ChildDef = r:get('Child Def')
			assert.are.same(ChildDef:Render(), {
				foo = 'bar',
				blorg = 'pow'
			})
		end)

		it("inherits non-overlapping simple properties from multiple parents", function ()
			local r = Registry:new()
			r:register('First Base Def'):Attrs{
				foo = 'bar',
			}
			r:register('Second Base Def'):Attrs{
				blorg = 'pow'
			}

			r:register('Child Def'):Extends('First Base Def'):Extends('Second Base Def')
			local ChildDef = r:get('Child Def')
			assert.are.same(ChildDef:Render(), {
				foo = 'bar',
				blorg = 'pow'
			})
		end)

		it("inherits and overwrites simple overlapping properties from multiple parents", function ()
			local r = Registry:new()
			r:register('First Base Def'):Attrs{
				blorg = 'foo',
			}
			r:register('Second Base Def'):Attrs{
				blorg = 'pow'
			}

			r:register('Child Def'):Extends('First Base Def'):Extends('Second Base Def')
			local ChildDef = r:get('Child Def')
			assert.are.same(ChildDef:Render(), {
				blorg = 'pow'
			})
		end)

		it("inherits subtable properties", function ()
			local r = Registry:new()
			r:register('Base Def'):Attrs{
				foo = {
					subA = 'baz',
					subB = 'qux'
				}
			}
			r:register('Child Def'):Extends('Base Def')
			local ChildDef = r:get('Child Def')
			assert.are.same(ChildDef:Render(), {
				foo = {
					subA = 'baz',
					subB = 'qux'
				}
			})
		end)

		it("inherits nested subtable properties", function ()
			local r = Registry:new()
			r:register('Base Def'):Attrs{
				foo = {
					one = {
						blorg = {
							thing = 'baz',
						}
					}
				}
			}
			r:register('Child Def'):Extends('Base Def')
			local ChildDef = r:get('Child Def')
			assert.are.same(ChildDef:Render(), {
				foo = {
					one = {
						blorg = {
							thing = 'baz',
						}
					}
				}
			})
		end)

		it("inherits and merges non-overlapping subtable properties from multiple parents", function ()
			local r = Registry:new()
			r:register('First Def'):Attrs{
				foo = {
					subA = 'baz',
				}
			}
			r:register('Second Def'):Attrs{
				foo = {
					subB = 'qux',
				}
			}

			r:register('Child Def'):Extends('First Def'):Extends('Second Def')
			local ChildDef = r:get('Child Def')
			assert.are.same(ChildDef:Render(), {
				foo = {
					subA = 'baz',
					subB = 'qux'
				}
			})
		end)

		it("inherits and merges overlapping subtable properties from multiple parents", function ()
			local r = Registry:new()
			r:register('First Def'):Attrs{
				foo = {
					subA = 'baz',
				}
			}
			r:register('Second Def'):Attrs{
				foo = {
					subA = 'qux',
				}
			}

			r:register('Child Def'):Extends('First Def'):Extends('Second Def')
			local ChildDef = r:get('Child Def')
			assert.are.same(ChildDef:Render(), {
				foo = {
					subA = 'qux',
				}
			})
		end)

	end)

	describe("getKeySource", function ()
		it("identifies simple Attr keys as sourced from 'self'", function ()
			local r = Registry:new()
			r:register('Test Def'):Attrs{
				a = '1'
			}
			local def = r:get('Test Def')
			local source = def:getKeySource('a')
			assert.are.equal(def, source)
		end)
		it("identifies simple Extends keys as sourced from parent", function ()
			local r = Registry:new()
			r:register('Base Def'):Attrs{
				a = '1'
			}

			r:register('Test Def'):Extends('Base Def')
			local baseDef = r:get('Base Def')
			local childDef = r:get('Test Def')
			local source = childDef:getKeySource('a')
			assert.are.equal(baseDef, source)
		end)
		it("identifies subtable Attr keys as sourced from self", function ()
			local r = Registry:new()
			r:register('Test Def'):Attrs{
				subtable = {
					a = '1'
				}
			}

			local def = r:get('Test Def')
			local source = def:getKeySource('subtable')
			assert.are.equal(def, source)
		end)

		it("identifies subtable keys from Attr as sourced from self subtable", function ()
			local r = Registry:new()
			r:register('Test Def'):Attrs{
				subtable = {
					a = '1'
				}
			}

			local subtableDef = r:get('Test Def subtable')
			local source = subtableDef:getKeySource('a')
			assert.are.equal(subtableDef, source)
		end)

		it("identifies diamond inheritance keys as from the shared base", function ()
			local r = Registry:new()
			r:register('Base Def'):Attrs{
				a = '1'
			}
			r:register('Second Def'):Extends('Base Def')
			r:register('Third Def'):Extends('Base Def')

			r:register('Test Def'):Extends('Second Def'):Extends('Third Def')

			local baseDef = r:get('Base Def')
			local def = r:get('Test Def')
			local source = def:getKeySource('a')
			assert.are.equal(baseDef, source)
		end)
	end)
	describe("getOwnKeys", function ()
		it("correctly labels simple keys on a simple class", function ()
			local r = Registry:new()
			r:register('Simple Def'):Attrs{
				a = 1
			}
			local ownKeys = r:get('Simple Def'):getOwnKeys()
			assert.are.same(ownKeys, {
				a = 1
			})
		end)

		it("correctly skips simple inherited keys", function ()
			local r = Registry:new()
			r:register('Base Def'):Attrs{
				a = 1
			}

			r:register('Child Def'):Extends('Base Def')

			local ownKeys = r:get('Child Def'):getOwnKeys()
			assert.are.same(ownKeys, {})
		end)

		it("correctly labels nested keys on a simple class", function ()
			local r = Registry:new()
			r:register('Simple Def'):Attrs{
				a = {
					b = {
						c = 3
					}
				}
			}
			local ownKeys = r:get('Simple Def'):getOwnKeys()
			assert.are.same(ownKeys, {
				a = {
					b = {
						c = 3
					}
				}
			})
		end)

		it("correctly skips inherited nested keys", function ()
			local r = Registry:new()
			r:register('Base Def'):Attrs{
				a = {
					b = {
						c = 3
					}
				}
			}
			r:register('Child Def'):Extends('Base Def')
			local ownKeys = r:get('Child Def'):getOwnKeys()
			--TODO: is this sane?
			assert.are.same(ownKeys, {
				a = { b = {} }
			})
		end)

		it("correctly merges inherited nested keys", function ()
			local r = Registry:new()
			r:register('Base Def'):Attrs{
				a = {
					b = {
						c = 3
					}
				}
			}
			r:register('Child Def'):Extends('Base Def'):Attrs{
				a = {
					b = {
						foo = 'bar'
					}
				}
			}
			local ownKeys = r:get('Child Def'):getOwnKeys()
			assert.are.same(ownKeys, {
				a = {
					b = {
						foo = "bar"
					}
				}
			})
		end)
	end)
end)
