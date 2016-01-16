local Registry = require 'registry'
describe("registry object", function ()
	it("registers and gets new def", function ()
		local r = Registry:new()
		r:register('Simple Def')
		local TestDef = r:get('Simple Def')
		assert.truthy(TestDef)
	end)
	it("lists user for flat value", function ()
		local r = Registry:new()
		r:register('Base'):Attrs{
			foo = 'bar'
		}
		r:register('User'):Extends('Base')
		local users = r:findUsers('Base')
		assert.are.equal(users.foo.consumers[1], 'User')
		assert.are.equal(users.foo.value, 'bar')
	end)
	it("lists user for nested values on a single level", function ()
		local r = Registry:new()
		r:register('Base'):Attrs{
			foo = {
				bar = 'blorg'
			}
		}
		r:register('User'):Extends('Base')
		local users = r:findUsers('Base')
		assert.are.equal(users.foo.bar.consumers[1], 'User foo')
		assert.are.equal(users.foo.bar.value, 'blorg')
	end)
	it("lists user for deeply nested values", function ()
		local r = Registry:new()
		r:register('Base'):Attrs{
			foo = {
				bar = {
					baz = {
						blorg = 'a thing'
					}
				}
			}
		}
		r:register('User'):Extends('Base')
		local users = r:findUsers('Base')
		assert.are.equal(users.foo.bar.baz.blorg.consumers[1], 'User foo bar baz')
		assert.are.equal(users.foo.bar.baz.blorg.value, 'a thing')
	end)

	it("lists multiple users for simple values", function ()
		local r = Registry:new()
		r:register('Base'):Attrs{
			foo = 'bar'
		}
		r:register('Thing 1'):Extends('Base')
		r:register('Thing 2'):Extends('Base')
		r:register('Thing 3'):Extends('Base')
		local users = r:findUsers('Base')
		table.sort(users.foo.consumers)
		assert.are.same(users.foo.consumers, { 'Thing 1', 'Thing 2', 'Thing 3'})
		assert.are.equal(users.foo.value, 'bar')
	end)

	it("lists multiple users for nested values", function ()
		local r = Registry:new()
		r:register('Base'):Attrs{
			foo = {
				bar = {
					baz = {
						blorg = 'a thing'
					}
				}
			}
		}
		r:register('Thing 1'):Extends('Base')
		r:register('Thing 2'):Extends('Base')
		r:register('Thing 3'):Extends('Base')
		local users = r:findUsers('Base')
		table.sort(users.foo.bar.baz.blorg.consumers)
		assert.are.same(users.foo.bar.baz.blorg.consumers, {
			'Thing 1 foo bar baz', 'Thing 2 foo bar baz', 'Thing 3 foo bar baz'
		})
		assert.are.equal(users.foo.bar.baz.blorg.value, 'a thing')
	end)


	it("lists deep inheritance users for simple values", function ()
		local r = Registry:new()
		r:register('Base'):Attrs{
			foo = 'bar'
		}
		r:register('First'):Extends('Base')
		r:register('Second'):Extends('First')
		r:register('Third'):Extends('Second')
		local users = r:findUsers('Base')
		table.sort(users.foo.consumers)
		assert.are.same(users.foo.consumers, { 'First', 'Second', 'Third' })
		assert.are.equal(users.foo.value, 'bar')
	end)

	it("lists deep inheritance users for nested values", function ()
		local r = Registry:new()
		r:register('Base'):Attrs{
			foo = {
				bar = {
					baz = {
						blorg = 'a thing'
					}
				}
			}

		}

		r:register('First'):Extends('Base')
		r:register('Second'):Extends('First')
		r:register('Third'):Extends('Second')
		local users = r:findUsers('Base')
		table.sort(users.foo.bar.baz.blorg.consumers)
		assert.are.same(users.foo.bar.baz.blorg.consumers, {
			'First foo bar baz', 'Second foo bar baz', 'Third foo bar baz'
		})
		assert.are.equal(users.foo.bar.baz.blorg.value, 'a thing')
	end)

	it("does not include empty subtables", function ()
		local r = Registry:new()
		r:register('Base'):Attrs{
			foo = {
				bar = {
					baz = {
						blorg = 'a thing'
					}
				}
			},
			what = {
				dance = "dance revolution"
			}
		}

		local users = r:findUsers('Base')
		assert.are.same(users, {})
	end)

	it("does not allow duplicate implementations", function ()
		local r = Registry:new()
		r:register('Foo')
		assert.has_error(function() r:register('Foo') end, "Foo is already a registered implementation!")
	end)

	it("does not allow duplicate abstract classes", function ()
		local r = Registry:new()
		r:registerAbstract('Foo')
		assert.has_error(function() r:registerAbstract('Foo') end, "Foo is already a registered abstract class!")
	end)

	it("does not allow any duplicates", function ()
		local r = Registry:new()
		r:registerAbstract('Foo')
		assert.has_error(function() r:register('Foo') end, "Foo is already a registered abstract class!")
	end)

	it("knows whether a class is abstract or implementation", function ()
		local r = Registry:new()
		r:registerAbstract('Foo')
		r:register('Bar')
		assert.equals(r:type('Bar'), 'implementation')
		assert.equals(r:type('Foo'), 'abstract')
		assert.equals(r:type('fake'), 'unregistered')
	end)

end)
