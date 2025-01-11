import Foundation

enum StubBehavior {
    case never
    case immediate
    case delay(seconds: TimeInterval)
}

extension ApiClient {
    final class func neverStub(_: Api) -> StubBehavior {
        .never
    }
    
    final class func ImmediatelyStub(_: Api) -> StubBehavior {
        .immediate
    }
    
    final class func delayedStub(_ seconds: TimeInterval) -> (Api) -> StubBehavior {
        return { _ in
            .delay(seconds: seconds)
        }
    }
}
