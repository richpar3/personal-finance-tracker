import Foundation
import Supabase

let supabase: SupabaseClient = {
    guard
        let path      = Bundle.main.path(forResource: "Config", ofType: "plist"),
        let dict      = NSDictionary(contentsOfFile: path),
        let urlString = dict["SupabaseURL"] as? String,
        let key       = dict["SupabaseKey"] as? String,
        let url       = URL(string: urlString)
    else {
        fatalError(
            "Config.plist not found or missing keys. " +
            "Copy Config.plist.template → Config.plist and fill in your credentials."
        )
    }
    return SupabaseClient(supabaseURL: url, supabaseKey: key)
}()
