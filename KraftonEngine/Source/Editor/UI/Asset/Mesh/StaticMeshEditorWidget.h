#pragma once

#include "Editor/UI/Asset/AssetEditorWidget.h"
#include "Object/FName.h"
#include "Editor/Viewport/Asset/StaticMeshEditorViewportClient.h"
#include "Math/Vector.h"

struct FStaticMesh;
struct ImDrawList;
struct ImVec2;

class FStaticMeshEditorWidget : public FAssetEditorWidget
{
public:
	FStaticMeshEditorWidget();

	bool CanEdit(UObject* Object) const override;
	bool IsEditingObject(UObject* Object) const override;

	void Open(UObject* Object) override;
	void Close() override;
	void Tick(float DeltaTime) override;

	void CollectPreviewViewports(TArray<IEditorPreviewViewportClient*>& OutClients) const override;

	bool AllowsMultipleInstances() const override { return true; }

	void Render(float DeltaTime) override;

private:
	void RenderMeshStatsOverlay(ImDrawList* DrawList, const ImVec2& ViewportPos) const;
	void RenderDetailsPanel(FStaticMesh* Asset);
	void RenderMuzzleProbePanel();

private:
	FStaticMeshEditorViewportClient ViewportClient;

	uint32 InstanceId;
	FName PreviewWorldHandle = FName::None;
	FString WindowIdSuffix;

	bool bMuzzleProbeEnabled = true;
	FVector MuzzleProbeLocalOffset = FVector::ZeroVector;
	float MuzzleProbeAxisLength = 0.5f;
};
