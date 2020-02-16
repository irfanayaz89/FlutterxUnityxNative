#include <UnityFramework/UnityFramework.h>

UnityFramework* UnityFrameworkLoad()
{
    NSString* bundlePath = nil;
    bundlePath = [[NSBundle mainBundle] bundlePath];
    bundlePath = [bundlePath stringByAppendingString: @"/Frameworks/UnityFramework.framework"];

    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    if ([bundle isLoaded] == false) [bundle load];

    UnityFramework* ufw = [bundle.principalClass getInstance];
    if (![ufw appController])
    {
        // unity is not initialized
        [ufw setExecuteHeader: &_mh_execute_header];
        [ufw setDataBundleId: "com.unity3d.framework"];
    }
    return ufw;
}

int main(int argc, char* argv[])
{
    @autoreleasepool
    {
        id ufw = UnityFrameworkLoad();
        [ufw setDataBundleId: "com.unity3d.framework"];
        [ufw runUIApplicationMainWithArgc: argc argv: argv];
        return 0;
    }
}
