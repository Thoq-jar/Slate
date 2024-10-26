package slate

// Slate //
/**
 * Struct: Slate
 * Purpose: Define config structure
 * @see Begin
 */
type Slate struct {
	Slate struct {
		Project struct {
			PackageManager string `yaml:"package-manager"`
			RootDir        string `yaml:"root-dir"`
			Main           string `yaml:"main"`
			Host           string `yaml:"host"`
			Port           string `yaml:"port"`
		} `yaml:"project"`
		Pre     []map[string]string `yaml:"pre"`
		Post    []map[string]string `yaml:"post"`
		Scripts []map[string]string `yaml:"scripts"`
	} `yaml:"slate"`
}
