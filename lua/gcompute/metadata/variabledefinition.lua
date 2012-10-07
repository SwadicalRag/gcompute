local self = {}
GCompute.VariableDefinition = GCompute.MakeConstructor (self, GCompute.ObjectDefinition)

--- @param The name of this variable
-- @param typeName The type of this variable as a string or DeferredNameResolution or Type
function self:ctor (name, typeName)
	self.TypeParameterList = typeParameterList or GCompute.EmptyTypeParameterList
	
	self:SetType (typeName)
end

function self:CreateRuntimeObject ()
	return self.Type:CreateDefaultValue ()
end

--- Resolves the type of this variable
function self:ResolveTypes (globalNamespace)
	self.Type:Resolve (globalNamespace, self:GetContainingNamespace ())
	
	if self.Type:IsDeferredNameResolution () then
		if not self.Type:IsFailedResolution () then
			self.Type = self.Type:GetObject ()
		end
	end
end

--- Returns the type of this object
-- @return A Type representing the type of this object
function self:GetType ()
	return self.Type
end

function self:IsVariable ()
	return true
end

--- Sets the type of this object
-- @param type The Type of this object
function self:SetType (typeName)
	if typeName == nil then
	elseif type (typeName) == "string" then
		self.Type = GCompute.DeferredNameResolution (typeName)
	elseif typeName:IsDeferredNameResolution () then
		self.Type = typeName
	elseif typeName:IsType () then
		self.Type = typeName
	else
		GCompute.Error ("VariableDefinition:SetType : typeName must be a string, DeferredNameResolution or Type")
	end
end

--- Returns a string representing this VariableDefinition
-- @return A string representing this VariableDefinition
function self:ToString ()
	local type = self.Type and self.Type:GetFullName () or "[Unknown Type]"
	return "[Variable] " .. type .. " " .. (self:GetName () or "[Unnamed]")
end