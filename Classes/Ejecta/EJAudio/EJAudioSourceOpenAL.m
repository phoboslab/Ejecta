#import "EJAudioSourceOpenAL.h"

@implementation EJAudioSourceOpenAL


- (id)initWithPath:(NSString *)pathp {
	if( self = [super init] ) {
		path = [pathp retain];
	}
	return self;
}

- (void)dealloc {
	if( path ) {
		[path release];
	}
	
	if( sourceId ) {
		alDeleteSources(1, &sourceId);
	}
	if( bufferId ) {
		alDeleteBuffers(1, &bufferId);
	}
	
	[super dealloc];
}

- (void)load {
	if( sourceId || !path ) return; // already loaded or no path set?
	
	ALenum format;
	ALsizei size;
	ALsizei freq;
	
	NSURL * url = [NSURL fileURLWithPath:path];
	void * data = [self getAudioDataWithURL:url size:&size format:&format rate:&freq];

	if( !data ) {
		return;
	}
	
	alGenBuffers( 1, &bufferId );
	alBufferData( bufferId, format, data, size, freq ); 
	
	
	alGenSources(1, &sourceId); 
	alSourcei(sourceId, AL_BUFFER, bufferId);
	alSourcef(sourceId, AL_PITCH, 1.0f);
	alSourcef(sourceId, AL_GAIN, 1.0f);

	free(data);
	return;
}


- (void*)getAudioDataWithURL:(NSURL *)inFileURL 
						 size:(ALsizei *)outDataSize
					   format:(ALenum *)outDataFormat
					    rate:(ALsizei *)outSampleRate 
{
						
	OSStatus						err = noErr;	
	SInt64							theFileLengthInFrames = 0;
	AudioStreamBasicDescription		theFileFormat;
	UInt32							thePropertySize = sizeof(theFileFormat);
	ExtAudioFileRef					extRef = NULL;
	void*							theData = NULL;
	AudioStreamBasicDescription		theOutputFormat;

	// Open a file with ExtAudioFileOpen()
	err = ExtAudioFileOpenURL((CFURLRef)inFileURL, &extRef);
	if(err) { 
		NSLog(@"OpenALSource: ExtAudioFileOpenURL FAILED, Error = %ld", err); 
		goto Exit; 
	}
	
	// Get the audio data format
	err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &theFileFormat);
	if(err) { 
		NSLog(@"OpenALSource: ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = %ld", err); 
		goto Exit; 
	}
	if (theFileFormat.mChannelsPerFrame > 2) { 
		NSLog(@"OpenALSource: Unsupported Format, channel count is greater than stereo"); 
		goto Exit;
	}

	// Set the client format to 16 bit signed integer (native-endian) data
	// Maintain the channel count and sample rate of the original source format
	theOutputFormat.mSampleRate = theFileFormat.mSampleRate;
	theOutputFormat.mChannelsPerFrame = theFileFormat.mChannelsPerFrame;

	theOutputFormat.mFormatID = kAudioFormatLinearPCM;
	theOutputFormat.mBytesPerPacket = 2 * theOutputFormat.mChannelsPerFrame;
	theOutputFormat.mFramesPerPacket = 1;
	theOutputFormat.mBytesPerFrame = 2 * theOutputFormat.mChannelsPerFrame;
	theOutputFormat.mBitsPerChannel = 16;
	theOutputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
	
	// Set the desired client (output) data format
	err = ExtAudioFileSetProperty(extRef, kExtAudioFileProperty_ClientDataFormat, sizeof(theOutputFormat), &theOutputFormat);
	if( err ) { 
		NSLog(@"OpenALSource: ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat) FAILED, Error = %ld", err); 
		goto Exit; 
	}
	
	// Get the total frame count
	thePropertySize = sizeof(theFileLengthInFrames);
	err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileLengthFrames, &thePropertySize, &theFileLengthInFrames);
	if( err ) { 
		NSLog(@"OpenALSource: ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) FAILED, Error = %ld", err); 
		goto Exit; 
	}
	
	// Read all the data into memory
	UInt32 dataSize = theFileLengthInFrames * theOutputFormat.mBytesPerFrame;;
	theData = malloc(dataSize);
	if( theData ) {
		AudioBufferList		theDataBuffer;
		theDataBuffer.mNumberBuffers = 1;
		theDataBuffer.mBuffers[0].mDataByteSize = dataSize;
		theDataBuffer.mBuffers[0].mNumberChannels = theOutputFormat.mChannelsPerFrame;
		theDataBuffer.mBuffers[0].mData = theData;
		
		// Read the data into an AudioBufferList
		err = ExtAudioFileRead(extRef, (UInt32*)&theFileLengthInFrames, &theDataBuffer);
		if( err == noErr ) {
			// success
			*outDataSize = (ALsizei)dataSize;
			*outDataFormat = (theOutputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
			*outSampleRate = (ALsizei)theOutputFormat.mSampleRate;
		}
		else { 
			// failure
			free (theData);
			theData = NULL; // make sure to return NULL
			NSLog(@"OpenALSource: ExtAudioFileRead FAILED, Error = %ld", err); 
			goto Exit;
		}	
	}
	
Exit:
	// Dispose the ExtAudioFileRef, it is no longer needed
	if (extRef) {
		ExtAudioFileDispose(extRef);
	}
	return theData;
}

- (void)play {
	[self load];
	alSourcePlay( sourceId );
}

- (void)pause {
	alSourceStop( sourceId );
}

- (void)setLooping:(BOOL)loop {
	alSourcei( sourceId, AL_LOOPING, loop ? AL_TRUE : AL_FALSE );
}

- (void)setVolume:(float)volume {
	alSourcef( sourceId, AL_GAIN, volume );
}

- (float)getCurrentTime {
	float time;
	alGetSourcef( sourceId, AL_SEC_OFFSET,  &time );
	return time;
}

- (void)setCurrentTime:(float)time {
	alSourcef( sourceId, AL_SEC_OFFSET,  time );
}

@end
