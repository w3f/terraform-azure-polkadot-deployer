package test

import (
    "fmt"
    "os"
    "strings"
    "testing"

    "github.com/gruntwork-io/terratest/modules/azure"
    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/gruntwork-io/terratest/modules/test-structure"
    "github.com/stretchr/testify/require"
)

func createTerraformOptions(t *testing.T, terraformDir string) {
    clientId := os.Getenv("ARM_CLIENT_ID")
    require.NotEmpty(t, clientId, "ARM_CLIENT_ID variable is not set")

    clientSecret := os.Getenv("ARM_CLIENT_SECRET")
    require.NotEmpty(t, clientSecret, "ARM_CLIENT_SECRET variable is not set")

    subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
    require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID variable is not set")

    nodeCount := 2
    servicePort := 30100
    location := azure.GetRandomStableRegion(t, []string{"centralus", "eastus", "northeurope", "westeurope"}, nil, subscriptionID)
    uniqueID := strings.ToLower(random.UniqueId())
    clusterName := fmt.Sprintf("test-polkadot-%s", uniqueID)

    terraformOptions := &terraform.Options{
        TerraformDir: terraformDir,
        Vars: map[string]interface{} {
            "client_id":     clientId,
            "client_secret": clientSecret,
            "cluster_name":  clusterName,
            "location":      location,
            "machine_type":  "Standard_B2s",
            "node_count":    nodeCount,
        },
        NoColor: true,
    }

    test_structure.SaveInt(t, terraformDir, "nodeCount", nodeCount)
    test_structure.SaveInt(t, terraformDir, "nodePort", servicePort)
    test_structure.SaveString(t, terraformDir, "clusterName", clusterName)
    test_structure.SaveString(t, terraformDir, "uniqueID", uniqueID)
    test_structure.SaveTerraformOptions(t, terraformDir, terraformOptions)
}

func createHelmOptions(t *testing.T, terraformDir string) {
    helmValues := map[string]string{
        "image.repo":   "nginx",
        "image.tag":    "1.8",
        "service.type": "LoadBalancer",
    }

    helmValuesFile := test_structure.FormatTestDataPath(terraformDir, "HelmValues.json")
    test_structure.SaveString(t, terraformDir, "helmValuesFile", helmValuesFile)
    test_structure.SaveTestData(t, helmValuesFile, helmValues)
}
