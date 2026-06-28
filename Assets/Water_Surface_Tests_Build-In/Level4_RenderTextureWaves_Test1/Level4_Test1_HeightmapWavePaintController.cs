using System.Collections;
using UnityEngine;

public class Level4_Test1_HeightmapPaintWaveController : MonoBehaviour
{
    [SerializeField] private Camera mainCamera;
    [SerializeField] private Camera paintCamera;
    [SerializeField] private Transform brushWhiteQuad;
    [SerializeField] private Transform brushBlackQuad;
    [SerializeField] private Renderer greyPlaneRenderer;

    [SerializeField] private ParticleSystem blinkingParticleSystem;

    [SerializeField] private float brushWhiteHeightOffset = 0.1f;
    [SerializeField] private float stepWhiteDistance = 0.1f;
    [SerializeField] private float brushBlackHeightOffset = 0.2f;
    [SerializeField] private float blackDistanceLerp = 0.333f;

    [SerializeField] private Material whiteBlobMaterial;
    [SerializeField] private Material blackBlobMaterial;
    private float _alpha = 0;
    private float _alphaSpeed = 1;
    private bool _alphaFadeIn = false;
    private bool _alphaFadeOut = false;

    private Vector3 lastWhiteHitPosition;
    private Vector3 lastBlackHitPosition;
    private bool isDrawing = false;
    private Vector3 hitPosition;

    void Start()
    {
        //greyPlaneRenderer.material = initialGreyMaterial;

        //brushWhiteQuad.gameObject.SetActive(false);
        //brushBlackQuad.gameObject.SetActive(false);

        whiteBlobMaterial.color = new Color(1, 1, 1, 0);
        blackBlobMaterial.color = new Color(1, 1, 1, 0);

        //StartCoroutine(CaptureFirstFrame());
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

                _alphaFadeIn = true;
                _alphaFadeOut = false;
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

                brushBlackQuad.localPosition = Vector3.Lerp(brushBlackQuad.localPosition, lastWhiteHitPosition + new Vector3(0, brushBlackHeightOffset, 0), blackDistanceLerp);
            }
        }

        if (Input.GetMouseButtonUp(0))
        {
            isDrawing = false;
            //brushWhiteQuad.gameObject.SetActive(false);
            //brushBlackQuad.gameObject.SetActive(false);
            _alphaFadeIn = false;
            _alphaFadeOut = true;
        }

        if (_alphaFadeIn)
        {
            _alpha += Time.deltaTime * _alphaSpeed * 2f;
            if (_alpha >= 1)
            {
                _alphaFadeIn = false;
                _alpha = 1;
            }
        }

        if (_alphaFadeOut)
        {
            _alpha -= Time.deltaTime * _alphaSpeed;
            if (_alpha <= 0)
            {
                _alphaFadeOut = false;
                _alpha = 0;
            }
        }

        whiteBlobMaterial.color = new Color(1, 1, 1, _alpha);
        blackBlobMaterial.color = new Color(1, 1, 1, _alpha);
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

        //greyPlaneRenderer.material = renderTextureMaterial;
    }

    private IEnumerator CaptureOneFrame()
    {
        //brushWhiteQuad.gameObject.SetActive(true);
        //brushBlackQuad.gameObject.SetActive(true);
        blinkingParticleSystem.transform.localPosition = brushWhiteQuad.localPosition;
        blinkingParticleSystem.Emit(1);

        //paintCamera.enabled = true;
        //paintCamera.Render();

        yield return new WaitForEndOfFrame();

        //paintCamera.enabled = false;

        //brushWhiteQuad.gameObject.SetActive(false);
        //brushBlackQuad.gameObject.SetActive(false);

        //lastBlackHitPosition = Vector3.Lerp(lastBlackHitPosition, lastWhiteHitPosition, blackDistanceLerp);

        //brushBlackQuad.localPosition = lastBlackHitPosition + new Vector3(0, brushBlackHeightOffset, 0);
        //blackParticleSystem.transform.localPosition = brushBlackQuad.localPosition;
        //blackParticleSystem.Emit(1);
    }

    private IEnumerator CaptureOneFrame_dummy()
    {
        yield return new WaitForEndOfFrame();

        lastBlackHitPosition = Vector3.Lerp(lastBlackHitPosition, lastWhiteHitPosition, blackDistanceLerp);

        brushBlackQuad.localPosition = lastBlackHitPosition + new Vector3(0, brushBlackHeightOffset, 0);
    }
}