using UnityEngine;

public class FCP_ExampleScript : MonoBehaviour
{

    public bool getStartingColorFromMaterial;
    public FlexibleColorPicker fcp;
    public Material material;

    public string colorName = "_Color"; // Added

    private void Start()
    {
        if (getStartingColorFromMaterial)
            fcp.color = material.GetColor(colorName);

        fcp.onColorChange.AddListener(OnChangeColor);
    }

    private void OnChangeColor(Color co)
    {
        material.SetColor(colorName, co);
    }
}
