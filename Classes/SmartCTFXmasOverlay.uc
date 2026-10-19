class SmartCTFXmasOverlay extends Info;
var SmartCTFSettings Settings;
#exec texture import name=SmoothSnow file="Textures\SmoothSnow.pcx" mips=on flags=0
var float LastWidth,LastHeight;

#exec texture import name=santa file="Textures\santa.pcx" mips=off flags=2
#exec texture import name=present file="Textures\present.pcx" mips=off flags=2

struct ParticleInfo {                   // Snow particle description struct.
	var float size;
	var float cx;                       // Horizontal offset.
	var float cy;                       // Vertical offset.
	var float ct;                       // Time offset.
	var float waveFreq;                 // Particle wave frequency.
	var float waveAmplitude;            // Amplitude of the wave.
	var float dy;                       // Vertical base velocity.
	var float dx;                       // Horizontal base velocity.
	var color col;                      // Color of the particle.
};

var color baseColor;                    // Base color of the snow flakes.
var bool bSnowInitialized;              // Whether the particles have been initialized.

var ParticleInfo particles[100];        // Current particles displayed.
var float lastUpdateTime;               // Last time the particles were rendered.

var float minDX;                        // Minimum horizontal base velocity.
var float maxDX;                        // Maximum horizontal base velocity.
var float minDY;                        // Minimum vertical base velocity.
var float maxDY;                        // Maximum vertical base velocity.
var float minWaveAmplitude;             // Minimum wave amplitude.
var float maxWaveAmplitude;             // Maximum wave amplitude.

// Non scaled constants.
const minWaveFreq = 0.25;               // Minimum wave frequency.
const maxWaveFreq = 1.0;                // Maximum wave frequency.
const minGlow = 0.40;                   // Minimum snow flake sprite glow.
const maxGlow = 1.00;                   // Maximum snow flake sprite glow.

// Scaled constants (set for a resolution of 1280x1024 px).
const scaleMinDX = -20.0;
const scaleMaxDX = 20.0;
const scaleMinDY = 25.0;
const scaleMaxDY = 85.0;
const scaleMinWaveAmplitude = 8;
const scaleMaxWaveAmplitude = 22;
const scaleWidth = 1280;
const scaleHeight = 1024;

const santaTextureWidth = 128;             // Width of the santa texture.
const santaTextureHeight = 128;           // Height of the santa texture.

const presentTextureWidth = 128;           // Width of the present texture.
const presentTextureHeight = 128;         // Height of the present texture.

simulated function renderSnow(Canvas c) {
	local int baseX, baseY;
	local int index;
	local Texture sprite;
	local float cx, cy;

	// Update position of each particle.
	updateSnow(c);

	// Draw each particle.
	c.style = ERenderStyle.STY_Translucent;
	for (index = 0; index < arrayCount(particles); index++) {
		// Set position.
		cx = particles[index].cx;
		cy = particles[index].cy;
		cx += sin(particles[index].ct * particles[index].waveFreq * 2 * pi) * particles[index].waveAmplitude;
		c.setPos(cx, cy);

		// Draw particle sprite.
		c.drawColor = particles[index].col;
		sprite = Texture'SmoothSnow';
		c.drawTile(sprite, particles[index].size*DrawScale, particles[index].size*DrawScale, 0, 0, sprite.uSize, sprite.vSize);
	}
	
	if (Settings.bXmasImages) // whether to display the Sexy Xmas images! :D
	{
    // Draw Santa
	  baseX = c.clipX - (santaTextureWidth+16)*DrawScale;
	  baseY = c.clipY - (santaTextureHeight+16)*DrawScale;
	
    c.style = ERenderStyle.STY_Normal;
    c.drawColor = BaseColor;
  
	  c.setPos(baseX, baseY);
    c.drawTile(Texture'santa', santaTextureWidth*DrawScale, santaTextureHeight*DrawScale, 0.0, 0.0, santaTextureWidth, santaTextureHeight);
  
    // Draw presents
	  baseX = 16*DrawScale;
	  baseY = c.clipY - (presentTextureHeight+16)*DrawScale;
	
	  c.style = ERenderStyle.STY_Normal;
    c.drawColor = BaseColor;
  
	  c.setPos(baseX, baseY);
	  c.drawTile(Texture'present', presentTextureWidth*DrawScale, presentTextureHeight*DrawScale, 0.0, 0.0, presentTextureWidth, presentTextureHeight);
  }
}

simulated function updateSnow(Canvas c) {
	local float deltaTime;
	local int index;

	// Prepare for update.
	setupScalars(c);
	if (!bSnowInitialized || LastWidth!=c.ClipX || LastHeight!=c.ClipY) {
        LastWidth=c.ClipX; LastHeight=c.ClipY;
		initializeSnow(c);
	}
	deltaTime = fMin(0.5, level.timeSeconds - lastUpdateTime);

	// Move each particle.
	for (index = 0; index < arrayCount(particles); index++) {
		particles[index].cx += particles[index].dx * deltaTime;
		particles[index].cy += particles[index].dy * deltaTime;
		particles[index].ct += deltaTime / fMax(0.01,level.timeDilation);

		// Check if particle has left the screen.
		if (particles[index].cy > c.clipY) {
			// It has, reset particle.
			initializeParticle(index, c, true);
		}
	}
	lastUpdateTime = level.timeSeconds;
}

simulated function initializeSnow(Canvas c) {
	local int index;
	bSnowInitialized = true;

	// Initialize each particle.
	for (index = 0; index < arrayCount(particles); index++) {
		initializeParticle(index, c);
	}
	lastUpdateTime = level.timeSeconds;
}

simulated function initializeParticle(int index, Canvas c, optional bool bReset) {
    particles[index].size = 10 + fRand()*30;
	particles[index].cx = fRand() * c.clipX;
	if (bReset) {
		particles[index].cy = -Texture'SmoothSnow'.VSize;
	} else {
		particles[index].cy = fRand() * c.clipY;
	}
	particles[index].ct = 0.0;
	particles[index].dx = fRand() * (maxDX - minDX) + minDX;
	particles[index].dy = fRand() * (maxDY - minDY) + minDY;
	particles[index].waveFreq = fRand() * (maxWaveFreq - minWaveFreq) + minWaveFreq;
	particles[index].waveAmplitude = fRand() * (maxWaveAmplitude - minWaveAmplitude) + minWaveAmplitude;
	particles[index].waveFreq *= particles[index].dy / maxDY;
	particles[index].waveAmplitude *= particles[index].dy / maxDY;

	if (Settings.bFestiveSnow) {
		particles[index].col.r = rand(256);
		particles[index].col.g = rand(256);
		particles[index].col.b = rand(256);
	} else {
		particles[index].col = baseColor * (fRand() * (maxGlow - minGlow) + minGlow);
	}
}

simulated function setupScalars(Canvas c) {
    DrawScale=fMin(c.ClipX/1280.0,c.ClipY/1024.0);
	minDX = scaleMinDX / scaleWidth * c.clipX;
	maxDX = scaleMaxDX / scaleWidth * c.clipX;
	minDY = scaleMinDY / scaleHeight * c.clipY;
	maxDY = scaleMaxDY / scaleHeight * c.clipY;
	minWaveAmplitude = scaleMinWaveAmplitude / scaleWidth * c.clipX;
	maxWaveAmplitude = scaleMaxWaveAmplitude / scaleWidth * c.clipX;
}

defaultproperties
{
    RemoteRole=ROLE_None
    bHidden=True
	BaseColor=(R=255,G=255,B=255)
}
