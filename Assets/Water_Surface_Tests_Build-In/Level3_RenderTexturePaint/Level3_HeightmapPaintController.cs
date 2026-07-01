// Created by Alexander Tkachenko aka ALT , ALTernative.MS https://www.artstation.com/alternative_ms
using System.Collections;
using UnityEngine;

public class Level3_HeightmapPaintController : MonoBehaviour
{
    [SerializeField] private Camera mainCamera;
    [SerializeField] private Camera paintCamera;
    [SerializeField] private Transform brushWhiteQuad;
    [SerializeField] private Transform brushBlackQuad;
    [SerializeField] private Renderer greyPlaneRenderer;

    [SerializeField] private Material initialGreyMaterial;
    [SerializeField] private Material renderTextureMaterial;

    [SerializeField] private float brushWhiteHeightOffset = 0.1f;
    [SerializeField] private float stepWhiteDistance = 0.1f;
    [SerializeField] private float brushBlackHeightOffset = 0.2f;
    [SerializeField] private float blackDistanceLerp = 0.333f;

    private Vector3 lastWhiteHitPosition;
    private Vector3 lastBlackHitPosition;
    private bool isDrawing = false;
    private Vector3 hitPosition;

    void Start()
    {
        greyPlaneRenderer.material = initialGreyMaterial;

        brushWhiteQuad.gameObject.SetActive(false);
        brushBlackQuad.gameObject.SetActive(false);

        StartCoroutine(CaptureFirstFrame());
    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            if (GetClickPoint())
            {
                brushWhiteQuad.localPosition = hitPosition + new Vector3(0, brushWhiteHeightOffset, 0);
                brushBlackQuad.localPosition = hitPosition + new Vector3(0, brushBlackHeightOffset, 0);
                lastWhiteHitPosition = hitPosition;
                lastBlackHitPosition = hitPosition;
                StartCoroutine(CaptureOneFrame());
                isDrawing = true;
            }
        }

        if (Input.GetMouseButton(0) && isDrawing)
        {
            if (GetClickPoint())
            {
                brushWhiteQuad.localPosition = hitPosition + new Vector3(0, brushWhiteHeightOffset, 0);

                float distance = Vector3.Distance(hitPosition, lastWhiteHitPosition);

                if (distance >= stepWhiteDistance)
                {
                    lastWhiteHitPosition = hitPosition;
                    StartCoroutine(CaptureOneFrame());
                }
            }
        }

        if (Input.GetMouseButtonUp(0))
        {
            isDrawing = false;
            brushWhiteQuad.gameObject.SetActive(false);
            brushBlackQuad.gameObject.SetActive(false);
        }
    }

    private bool GetClickPoint()
    {
        hitPosition = Vector3.zero;

        Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit))
        {
            if (hit.transform == this.transform)
            {
                hitPosition = hit.point;
                return true;
            }
        }
        return false;
    }

    private IEnumerator CaptureFirstFrame()
    {
        paintCamera.enabled = true;
        paintCamera.Render();

        yield return new WaitForEndOfFrame();

        paintCamera.enabled = false;

        greyPlaneRenderer.material = renderTextureMaterial;
    }

    private IEnumerator CaptureOneFrame()
    {
        brushWhiteQuad.gameObject.SetActive(true);
        brushBlackQuad.gameObject.SetActive(true);

        paintCamera.enabled = true;
        paintCamera.Render();

        yield return new WaitForEndOfFrame();

        paintCamera.enabled = false;

        brushWhiteQuad.gameObject.SetActive(false);
        brushBlackQuad.gameObject.SetActive(false);

        lastBlackHitPosition = Vector3.Lerp(lastBlackHitPosition, lastWhiteHitPosition, blackDistanceLerp);

        brushBlackQuad.localPosition = lastBlackHitPosition + new Vector3(0, brushBlackHeightOffset, 0);
    }
}