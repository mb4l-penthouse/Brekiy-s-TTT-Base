AddCSLuaFile()

if CLIENT then
   SWEP.PrintName = "G3SG1"
   SWEP.Slot = 2
   SWEP.Icon = "vgui/ttt/icon_scout"
   SWEP.IconLetter = "i"
end

SWEP.Base = "weapon_ttt_brekiy_base"
SWEP.HoldType = "ar2"

SWEP.Primary.Ammo = "357"
SWEP.Primary.Delay = 0.37
SWEP.Primary.Recoil = 3.5
SWEP.Primary.Cone = 0.028
SWEP.Primary.Damage = 55
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 20
SWEP.Primary.ClipMax = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Sound = Sound("Weapon_g3.shot")
SWEP.Secondary.Sound = Sound( "Default.Zoom" )
SWEP.HeadshotMultiplier = 2.5
SWEP.CrouchBonus 				 	= 0.7
SWEP.MovePenalty			 	 	= 2
SWEP.JumpPenalty			 	 	= 5
SWEP.MaxCone 					 	= 0.09

SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 60
SWEP.ViewModel = Model( "models/weapons/cstrike/c_snip_g3sg1.mdl" )
SWEP.WorldModel = Model( "models/weapons/w_snip_g3sg1.mdl" )

SWEP.IronSightsPos = Vector( 5, -15, -2 )
SWEP.IronSightsAng = Vector( 2.6, 1.37, 3.5 )

SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_357_ttt"
SWEP.InLoadoutFor = { nil }
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false

local ConeNoscope = 0.0335
local ConeScope = 0.0018

function SWEP:GetPrimaryCone()
   local cone = self.Primary.Cone or 0.2
   -- accuracy bonus when sighting
   return self:GetIronsights() and (cone * 0.05) or cone
end

function SWEP:SetZoom( state )
   if CLIENT then
      return
   elseif IsValid( self.Owner ) and self.Owner:IsPlayer() then
      if state then
         self.Owner:SetFOV( 15, 0.2 )
      else
         self.Owner:SetFOV( 0, 0.2 )
      end
   end
end

function SWEP:PrimaryAttack( worldsnd )
   self.BaseClass.PrimaryAttack( self, worldsnd )
   self:SetNextSecondaryFire( CurTime() + 0.1 )
end

function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self:GetNextSecondaryFire() > CurTime() then return end

   local bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )
	
   if SERVER then
      self:SetZoom( bIronsights )
   else
      self:EmitSound( self.Secondary.Sound )
   end

   self:SetNextSecondaryFire( CurTime() + 0.3 )
end

function SWEP:PreDrop()
   self:SetZoom( false )
   self:SetIronsights( false )
   return self.BaseClass.PreDrop( self )
end

function SWEP:Reload()
   if ( self:Clip1() == self.Primary.ClipSize or self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then return end
   self:DefaultReload( ACT_VM_RELOAD )
   self:SetIronsights( false )
   self:SetZoom( false )
end

function SWEP:Holster()
   self:SetIronsights( false )
   self:SetZoom( false )
   return true
end

if CLIENT then
   local scope = surface.GetTextureID( "sprites/scope" )
   function SWEP:DrawHUD()
      if self:GetIronsights() then
         surface.SetDrawColor( 0, 0, 0, 255 )

         local scrW = ScrW()
         local scrH = ScrH()

         local x = scrW / 2.0
         local y = scrH / 2.0
         local scope_size = scrH

         local gap = 80
         local length = scope_size
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 0
         length = 50
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         local sh = scope_size / 2
         local w = ( x - sh ) + 2
         surface.DrawRect( 0, 0, w, scope_size )
         surface.DrawRect( x + sh - 2, 0, w, scope_size )
         surface.DrawLine( 0, 0, scrW, 0 )
         surface.DrawLine( 0, scrH - 1, scrW, scrH - 1 )

         surface.SetDrawColor( 255, 0, 0, 255 )
         surface.DrawLine( x, y, x + 1, y + 1 )
         surface.SetTexture( scope )
         surface.SetDrawColor( 255, 255, 255, 255 )

         surface.DrawTexturedRectRotated( x, y, scope_size, scope_size, 0 )
      else
         return self.BaseClass.DrawHUD( self )
      end
   end

   function SWEP:AdjustMouseSensitivity()
      return ( self:GetIronsights() and 0.2 ) or nil
   end
end