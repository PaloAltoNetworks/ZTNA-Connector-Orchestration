#File used only if Stack is a Marketplace Stack
#Update based on Marketplace Listing - App Install Package - Image Oracle Cloud Identifier
#Each element is a single image from Marketpalce Catalog. Elements' name in map is arbitrary 


variable "marketplace_source_images" {
  type = map(object({
    ocid = string
    is_pricing_associated = bool
    compatible_shapes = list(string)
  }))
  default = {
    main_mktpl_image = {
      ocid = "ocid1.image.oc1..aaaaaaaam7laq5e5xe3wea5yir5naqpl6s6btuwchsxyfaxxvl7uuvr3kmaa"
      is_pricing_associated = false
      compatible_shapes = []
    }
  }
}
