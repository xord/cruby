#pragma once
#ifndef __CRUBY_CONFIG_H__
#define __CRUBY_CONFIG_H__


#import <TargetConditionals.h>


#if TARGET_OS_IOS
	#if TARGET_OS_SIMULATOR
		#if defined(__x86_64__)
		#define CRUBY_IPHONESIMULATOR_X86_64
		#elif defined(__arm64__)
		#define CRUBY_IPHONESIMULATOR_ARM64
		#endif
	#else
		#if defined(__x86_64__)
		#define CRUBY_IPHONEOS_X86_64
		#elif defined(__arm64__)
		#define CRUBY_IPHONEOS_ARM64
		#endif
	#endif
#else
	#if defined(__x86_64__)
	#define CRUBY_MACOSX_X86_64
	#elif defined(__arm64__)
	#define CRUBY_MACOSX_ARM64
	#endif
#endif


#define CRUBY_LIB_DIR_VERSION @


#endif//EOH
