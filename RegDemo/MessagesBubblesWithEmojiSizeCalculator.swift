import Foundation
import JSQMessagesViewController

class MessagesBubblesWithEmojiSizeCalculator: JSQMessagesBubblesSizeCalculator {
    
    init() {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "JSQMessagesBubblesSizeCalculator.cache"
        cache.countLimit = 200
        super.init(cache: cache, minimumBubbleWidth: UInt(UIImage.jsq_bubbleCompact().size.width), usesFixedWidthBubbles: false)
    }
    
    override func messageBubbleSize(for messageData: JSQMessageData!, at indexPath: IndexPath!, with layout: JSQMessagesCollectionViewFlowLayout!) -> CGSize {
        
        if let message = messageData as? JSQMessage, !message.isMediaMessage && message.text.unicodeScalars.count == 1 && message.text.unicodeScalars.first!.isEmoji {
            return CGSize(width: 100, height: 100)
        }
        
        return super.messageBubbleSize(for: messageData, at: indexPath, with: layout)
    }
    
}
