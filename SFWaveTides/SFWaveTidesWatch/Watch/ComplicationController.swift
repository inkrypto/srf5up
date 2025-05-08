import SwiftUI
import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "com.sfwavetides.tideinfo",
                displayName: "SF Wave Tides",
                supportedFamilies: [
                    .modularSmall,
                    .modularLarge,
                    .utilitarianSmall,
                    .utilitarianSmallFlat,
                    .utilitarianLarge,
                    .circularSmall,
                    .graphicCorner,
                    .graphicBezel,
                    .graphicCircular,
                    .graphicRectangular,
                    .graphicExtraLarge
                ]
            )
        ]
        
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do nothing
    }
    
    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Return the date when timeline data should end - usually the end of the day
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())
        handler(endOfDay)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the helper method to create the timeline entry
        createTimelineEntry(for: complication, date: Date()) { entry in
            handler(entry)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // For simplicity, we're not providing future timeline entries in this example
        // In a real app, you would calculate future tide times and provide entries
        handler(nil)
    }
    
    // MARK: - Helper Methods
    
    private func createTimelineEntry(for complication: CLKComplication, date: Date, completion: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // In a real app, this would fetch tide data and choose the appropriate template
        // For now, we'll use mock data
        
        let tideHeight = "4.2"
        let tideType = "H" // H for high tide, L for low tide
        let tideTime = "2:30 PM"
        let nextTideTime = "8:45 PM"
        
        // Create different templates based on the complication family
        var template: CLKComplicationTemplate?
        
        switch complication.family {
        case .modularSmall:
            let modularTemplate = CLKComplicationTemplateModularSmallStackText()
            modularTemplate.line1TextProvider = CLKSimpleTextProvider(text: "\(tideType) Tide")
            modularTemplate.line2TextProvider = CLKSimpleTextProvider(text: "\(tideHeight)ft")
            template = modularTemplate
            
        case .modularLarge:
            let modularTemplate = CLKComplicationTemplateModularLargeStandardBody()
            modularTemplate.headerTextProvider = CLKSimpleTextProvider(text: "SF Tides")
            modularTemplate.body1TextProvider = CLKSimpleTextProvider(text: "\(tideType == "H" ? "High" : "Low") Tide: \(tideHeight)ft")
            modularTemplate.body2TextProvider = CLKSimpleTextProvider(text: "Next: \(tideType == "H" ? "Low" : "High") at \(nextTideTime)")
            template = modularTemplate
            
        case .utilitarianSmall, .utilitarianSmallFlat:
            let utilTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
            utilTemplate.textProvider = CLKSimpleTextProvider(text: "\(tideType): \(tideHeight)ft")
            template = utilTemplate
            
        case .utilitarianLarge:
            let utilTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
            utilTemplate.textProvider = CLKSimpleTextProvider(text: "\(tideType == "H" ? "High" : "Low") Tide: \(tideHeight)ft")
            template = utilTemplate
            
        case .circularSmall:
            let circularTemplate = CLKComplicationTemplateCircularSmallStackText()
            circularTemplate.line1TextProvider = CLKSimpleTextProvider(text: tideType)
            circularTemplate.line2TextProvider = CLKSimpleTextProvider(text: tideHeight)
            template = circularTemplate
            
        case .graphicCorner:
            let graphicTemplate = CLKComplicationTemplateGraphicCornerStackText()
            graphicTemplate.innerTextProvider = CLKSimpleTextProvider(text: "\(tideType == "H" ? "High" : "Low")")
            graphicTemplate.outerTextProvider = CLKSimpleTextProvider(text: "\(tideHeight)ft")
            template = graphicTemplate
            
        case .graphicCircular:
            let graphicTemplate = CLKComplicationTemplateGraphicCircularStackText()
            graphicTemplate.line1TextProvider = CLKSimpleTextProvider(text: tideType)
            graphicTemplate.line2TextProvider = CLKSimpleTextProvider(text: tideHeight)
            template = graphicTemplate
            
        case .graphicRectangular:
            let graphicTemplate = CLKComplicationTemplateGraphicRectangularStandardBody()
            graphicTemplate.headerTextProvider = CLKSimpleTextProvider(text: "SF Tides")
            graphicTemplate.body1TextProvider = CLKSimpleTextProvider(text: "\(tideType == "H" ? "High" : "Low") Tide: \(tideHeight)ft")
            graphicTemplate.body2TextProvider = CLKSimpleTextProvider(text: "Next tide at \(nextTideTime)")
            template = graphicTemplate
            
        default:
            // Handle other complication families or return nil
            completion(nil)
            return
        }
        
        if let template = template {
            let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            completion(entry)
        } else {
            completion(nil)
        }
    }
}
