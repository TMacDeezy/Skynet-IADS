do
	
TestSkynetIADSAbstractElement = {}

function TestSkynetIADSAbstractElement:setUp()
	self.iads =  SkynetIADS:create()
	self.abstractElement = SkynetIADSAbstractElement:create(Group.getByName("SAM-SA-6-2"), self.iads)
end

function TestSkynetIADSAbstractElement:tearDown()
	self.abstractElement:cleanUp()
end

-- by default an abstractElement will return true if no power source or connection node ist set
function TestSkynetIADSAbstractElement:testHasActiveConnectionNodeByDefaultIfNoneIsSet()
	lu.assertEquals(self.abstractElement:genericCheckOneObjectIsAlive({}), true)
	lu.assertEquals(self.abstractElement:hasActiveConnectionNode(), true)
	lu.assertEquals(self.abstractElement:hasWorkingPowerSource(), true)
end

function TestSkynetIADSAbstractElement:testCheckOneGenericObjectAliveForUnitWorks()
	local unit = Unit.getByName('SAM-SA-6-2-connection-node-unit')
	self.abstractElement:addConnectionNode(unit)
	lu.assertEquals(self.abstractElement:genericCheckOneObjectIsAlive(self.abstractElement.connectionNodes), true)
	lu.assertEquals(self.abstractElement:hasActiveConnectionNode(), true)
	trigger.action.explosion(unit:getPosition().p, 1000)
	lu.assertEquals(self.abstractElement:genericCheckOneObjectIsAlive(self.abstractElement.connectionNodes), false)
	lu.assertEquals(self.abstractElement:hasActiveConnectionNode(), false)
end


function TestSkynetIADSAbstractElement:testCheckOneGenericObjectAliveForStaticObjectsWorks()
	local static = StaticObject.getByName('SAM-SA-6-2-coonection-node-static')
	self.abstractElement:addConnectionNode(static)
	lu.assertEquals(self.abstractElement:genericCheckOneObjectIsAlive(self.abstractElement.connectionNodes), true)
	lu.assertEquals(self.abstractElement:hasActiveConnectionNode(), true)
	trigger.action.explosion(static:getPosition().p, 1000)
	lu.assertEquals(self.abstractElement:genericCheckOneObjectIsAlive(self.abstractElement.connectionNodes), false)
	lu.assertEquals(self.abstractElement:hasActiveConnectionNode(), false)
end

function TestSkynetIADSAbstractElement:testPowerSourceAndConnectionNodeStaticObjectAndDestrutionSuccessful()

	local powerSource = StaticObject.getByName("test-ground-vehicle-power-source")
	local connectionNode = StaticObject.getByName("test-ground-vehicle-connection-node")
	
	--[[
	in this test there will be 4 calls to updateAutonomousStatesOfSAMSites
	because it is called when a connectionNode is added and when the powerSource is destroyed
	due to the if statement in onEvent its called twice when the connectionNode is destroyed
	onEvent could be rewritten to prevent call 3 and 4 however for the moment these double calls have no negative impact on the IADS code
	--]] 
	local numCalls = 0
	function self.iads:updateAutonomousStatesOfSAMSites(deadUnit)
		numCalls = numCalls + 1
		if numCalls == 1 then
			lu.assertEquals(deadUnit, nil)
		end
		if numCalls == 2 then
			lu.assertEquals(deadUnit, powerSource)
		end
		
		if numCalls == 3 then
			lu.assertEquals(deadUnit, connectionNode)
		end

		if numCalls == 4 then
			lu.assertEquals(deadUnit, connectionNode)
		end
		
	end

	self.abstractElement:addPowerSource(powerSource)
	self.abstractElement:addConnectionNode(connectionNode)
	lu.assertEquals(self.abstractElement:hasWorkingPowerSource(), true)
	lu.assertEquals(self.abstractElement:hasActiveConnectionNode(), true)
	trigger.action.explosion(powerSource:getPosition().p, 100)
	trigger.action.explosion(connectionNode:getPosition().p, 500)
	lu.assertEquals(self.abstractElement:hasWorkingPowerSource(), false)
	lu.assertEquals(self.abstractElement:hasActiveConnectionNode(), false)
	
	lu.assertEquals(numCalls, 4)
end	

function TestSkynetIADSAbstractElement:testGetNatoName()
	lu.assertEquals(self.abstractElement:getNatoName(), "UNKNOWN")
end

function TestSkynetIADSAbstractElement:testGetDescription()
	lu.assertEquals(self.abstractElement:getDescription(), "IADS ELEMENT: SAM-SA-6-2 | Type : UNKNOWN")
end

function TestSkynetIADSAbstractElement:testGetDCSRepresentation()
	lu.assertEquals(self.abstractElement:getDCSRepresentation(), Group.getByName("SAM-SA-6-2"))
end
	
end
