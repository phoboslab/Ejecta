#import <fenv.h>
#import <TargetConditionals.h>
#import <UIKit/UIKit.h>

#if !TARGET_IPHONE_SIMULATOR
#import <arm/arch.h>
#endif

int main(int argc, char *argv[]) {
	#ifdef _ARM_ARCH_7
		// Enable IEEE-754 denormal support. Needed for JavaScript's MIN_VALUE
		// and floating point arithmetic with small numbers
		fenv_t env;
		fegetenv(&env);
		env.__fpscr &= ~__fpscr_flush_to_zero;
		fesetenv(&env);
	#endif
	
	@autoreleasepool {
		return UIApplicationMain(argc, argv, nil, nil);
	}
}
