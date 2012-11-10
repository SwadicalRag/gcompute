local PANEL = {}

function PANEL:Init ()
	self.Frame = nil
	self.Tab = nil
	
	self.DocumentManager = nil
	
	self:AddEventListener ("Removed",
		function ()
			if self:GetContents () then
				self:GetContents ():Remove ()
			end
		end
	)
end

function PANEL:GetContents ()
	if not self.Contents or not self.Contents:IsValid () then
		self.Contents = self:GetChildren () [1]
	end
	return self.Contents
end

function PANEL:GetDocumentManager ()
	return self.DocumentManager
end

function PANEL:Paint (w, h)
end

function PANEL:PerformLayout ()
	if not self:GetContents () then return end
	
	self:GetContents ():SetPos (0, 0)
	self:GetContents ():SetSize (self:GetSize ())
	
	self:GetContents ():PerformLayout ()
end

function PANEL:RequestFocus ()
	if not self:GetContents () then return end
	self:GetContents ():RequestFocus ()
end

function PANEL:Select ()
	if self.Tab then self.Tab:Select () end
end

function PANEL:SetDocumentManager (documentManager)
	self.DocumentManager = documentManager
end

function PANEL:SetTab (tab)
	self.Tab = tab
end

Gooey.Register ("GComputeViewContainer", PANEL, "GPanel")